//
//  YoutubeTableViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit
import Alamofire
import Kingfisher

class YouTubeTableViewController: UITableViewController {
    var videos: [Video]?
    var query: String?
    var isFetching = false
    var hasSearched = false
    var pageToken: String?
    var scrollCount = 0 {
        didSet {
            search(query: query)
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func search(query: String?) {
        guard !isFetching, let query else { return }
        
        isFetching = true
        
        let endpoint = "https://www.googleapis.com/youtube/v3/search"
        var params: Parameters = [
            "part": "snippet",
            "q": query,
            "maxResults": 7,
            "topicId": "/m/01k8wb",
            "type": "video",
            "videoCategoryId": 28,
            "key": apiKey
        ]
        
        if let pageToken { params.updateValue(pageToken, forKey: "pageToken") }
        
        let alamo = AF.request(endpoint, method: .get, parameters: params)
        
        alamo.responseDecodable(of: YoutubeRoot.self) { [weak self] response in
            defer { self?.isFetching = false }
            
            switch response.result {
            case .success(let root):
                if self?.scrollCount == 0 {
                    self?.videos = root.items
                } else {
                    self?.videos?.append(contentsOf: root.items)
                    // Consider implementing the efficient row insertion here
                }
                
                self?.tableView.reloadData()
                self?.pageToken = root.nextPageToken
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (videos?.count ?? 1) - 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "video", for: indexPath)
        guard let video = videos?[indexPath.row] else { return cell }

        // Configure the cell...
        let thumbnailImage = cell.viewWithTag(1) as? UIImageView
        thumbnailImage?.kf.setImage(with: URL(string: video.snippet.thumbnails.medium.url))
        thumbnailImage?.contentMode = .scaleAspectFill
        
        let titleLabel = cell.viewWithTag(2) as? UILabel
        titleLabel?.text = video.snippet.title

        let channelTitleLabel = cell.viewWithTag(3) as? UILabel
        channelTitleLabel?.text = video.snippet.channelTitle

        return cell
    }
    
    // MARK: - UIScrollViewDelegate Implementation
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableViewContentSizeHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if hasSearched && position > (tableViewContentSizeHeight - 100 - scrollViewHeight) && !isFetching {
            scrollCount += 1
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "videoSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let controller = segue.destination as? YouTubePlayerViewController
            else { return }
            
            controller.videoId = videos?[indexPath.row].id.videoId
        }
        
    }
}

extension YouTubeTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isFetching = false
        hasSearched = true
        scrollCount = 0
        self.query = searchBar.text
        searchBar.resignFirstResponder()
    }
}
