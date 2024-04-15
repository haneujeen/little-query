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
    
    // OpenAI API...
    var suggestedQuestion: String?
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
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
            self?.fetchPreviews(query: searchText)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDebounceTimer?.invalidate()
        self.fetchPreviews(query: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func fetchPreviews(query: String?) {
        guard !isFetching, let query else { return }
        isFetching = true
        let group = DispatchGroup()
        
        // MARK: -
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
        
        // MARK: -
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
        
        // MARK: -
        let chatEndpoint = "https://api.openai.com/v1/chat/completions"
        let chatHeaders: HTTPHeaders = [
            "Authorization": "Bearer ",
            "Content-Type": "application/json"
        ]
        let chatParams: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                "role": "system",
                "content": """
                    You are a biology research assistant. Generate a prompts or suggestions for possible study tasks user might want to accomplish regarding their query.
                    Begin each prompt with a broad task or goal, followed by a more specific action or aspect of the main task. This initial prompts will give users a quick understanding of a complex task that can be handled through the platform.
                    Generate an initial question based on that initial prompt that guides the user further. Construct a JSON object with prompt
                     and question in the following format:
                    {
                        "prompt": {"task": "Some broad task", "action": "Specific action or aspect"},
                        "question": "What initial question would guide the user?"
                    }
                """
                ],
                ["role": "user","content": query]
            ]
        ]
        
        group.enter()
        AF.request(
            chatEndpoint,
            method: .post,
            parameters: chatParams,
            encoding: JSONEncoding.default,
            headers: chatHeaders
        ).responseDecodable(of: ChatRoot.self) { response in
            defer { group.leave() }
            switch response.result {
            case .success(let root):
                guard let content = root.choices.first?.message.content,
                      let contentData = content.data(using: .utf8),
                      let initialContent = try? JSONDecoder().decode(InitialContent.self, from: contentData)
                else { return }
                
                self.taskLabel.text = initialContent.prompt.task
                self.actionLabel.text = initialContent.prompt.action
                self.suggestedQuestion = initialContent.question
                print(self.suggestedQuestion)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        group.notify(queue: .main) {
            self.isFetching = false
            // Handle completion of all requests here
        }
    }

}
