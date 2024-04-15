//
//  MainViewController.swift
//  LittleQuery

import UIKit
import Alamofire

class MainViewController: UIViewController {
    // For initial data display
    var engines = ["Google Scholar", "YouTube", "ChatGPT"]
    var articles: [Article]?
    let SerpApiKey
    var videos: [Video]?
    var pageToken: String?
    let YTApiKey
    
    // For search bar
    var searchDebounceTimer: Timer?
    var query: String?
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Flags
    var isFetching = false
    
    // Mini tables
    let GSMiniTableManager = MiniTableManager(engine: .GoogleScholar)
    let youtubeMiniTableManager = MiniTableManager(engine: .YouTube)
    @IBOutlet weak var GSMiniTable: UITableView!
    @IBOutlet weak var youtubeMiniTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        GSMiniTable.delegate = GSMiniTableManager
        GSMiniTable.dataSource = GSMiniTableManager
        youtubeMiniTable.delegate = youtubeMiniTableManager
        youtubeMiniTable.dataSource = youtubeMiniTableManager
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toGoogleScholar" {
            
            guard let articles = GSMiniTableManager.articles,
                  let destination = segue.destination as? GoogleScholarTableViewController
            else { return }
            
            destination.query = searchBar.text
            destination.hasSearched = true
            destination.articles = articles
            destination.tableView.reloadData()
            
        } else if segue.identifier == "toYoutube" {
            guard let videos = youtubeMiniTableManager.videos,
                  let destination = segue.destination as? YouTubeTableViewController
            else { return }
            
            destination.query = searchBar.text
            destination.hasSearched = true
            destination.videos = videos
            destination.pageToken = pageToken
            destination.tableView.reloadData()
        } else {
            
        }
    }

}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" { return }
        
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] _ in
            self?.search(query: searchText)
            
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDebounceTimer?.invalidate()
        self.search(query: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func search(query: String?) {
        guard !isFetching, let query else { return }
        isFetching = true
        let group = DispatchGroup()
        
        let googleScholarEndpoint = "https://serpapi.com/search?engine=google_scholar"
        let googleScholarParams: Parameters = ["q": query, "start": 0, "num": 10, "api_key": SerpApiKey]
        
        group.enter()
        AF.request(googleScholarEndpoint, parameters: googleScholarParams).responseDecodable(of: ScholarRoot.self) { [weak self] response in
            defer { group.leave() }
            switch response.result {
            case .success(let root):
                self?.articles = root.results
                self?.GSMiniTableManager.articles = root.results
                self?.GSMiniTable.reloadData()
            case .failure(let error):
                print("Google Scholar Error:", error.localizedDescription)
            }
        }
        
        let youtubeEndpoint = "https://www.googleapis.com/youtube/v3/search"
        let youtubeParams: Parameters = [
            "part": "snippet", "q": query, "maxResults": 7,
            "topicId": "/m/01k8wb", "type": "video", "videoCategoryId": 28, "key": YTApiKey
        ]
        
        group.enter()
        AF.request(youtubeEndpoint, parameters: youtubeParams).responseDecodable(of: YoutubeRoot.self) { [weak self] response in
            defer { group.leave() }
            switch response.result {
            case .success(let root):
                self?.videos = root.items
                self?.pageToken = root.nextPageToken
                self?.youtubeMiniTableManager.videos = root.items
                self?.youtubeMiniTable.reloadData()
            case .failure(let error):
                print("YouTube Error:", error.localizedDescription)
            }
        }
        
        group.notify(queue: .main) {
            self.isFetching = false
            // Handle completion of all requests here
            print("All requests completed.")
        }
    }

}
