//
//  GoogleScholarTableViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit

class GoogleScholarTableViewController: UITableViewController {
    let apiKey = "3e0d360330ffda3410e04ebabbdcae1068124e880e5fcbb3b2c75ba385d4e0e7"
    var query: String?
    var isFetching = false
    var hasSearched = false
    var page = 0 {
        didSet {
            createTask(query: query, page: page, size: 10)
        }
    }
    var articles: [Article]?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func buildRequest(query: String, page: Int, size: Int) -> URLRequest {
        let endpoint = "https://serpapi.com/search?engine=google_scholar&q=\(query)&hl=en&start=\(page)&api_key=\(apiKey)&num=\(size)"
        
        guard let endpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: endpoint)
        else { fatalError() }
        
        return URLRequest(url: url)
    }
    
    func createTask(query: String?, page: Int, size: Int) {
        guard !isFetching, let query else { return }
        let request = buildRequest(query: query, page: page * size, size: size)
        
        isFetching = true
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isFetching = false }
            
            if let error { print(error.localizedDescription); return }
            guard let data else { return }

            do {
                let root = try JSONDecoder().decode(ScholarRoot.self, from: data)
                let newArticles = root.results
                
                if page == 0 {
                    self?.articles = newArticles
                } else {
                    self?.articles?.append(contentsOf: newArticles)
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.resume()
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
        return articles?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)
        guard let article = articles?[indexPath.row] else { return cell }
        
        // Configure the cell...
        let titleLabel = cell.viewWithTag(1) as? UILabel
        titleLabel?.text = article.title
        let publicationLabel = cell.viewWithTag(2) as? UILabel
        publicationLabel?.text = article.publication.summary
        let snippetLabel = cell.viewWithTag(3) as? UILabel
        snippetLabel?.text = article.snippet

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate Implementation
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableViewContentSizeHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if hasSearched && position > (tableViewContentSizeHeight - 100 - scrollViewHeight) && !isFetching {
            page += 1
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        if segue.identifier == "articleSegue" {
            let controller = segue.destination as? GSDetailViewController
            
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let article = articles?[indexPath.row] else { return }
            
            controller?.url  = URL(string: article.link)
        }
    }
}

extension GoogleScholarTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hasSearched = true
        isFetching = false
        page = 0
        self.query = searchBar.text
        searchBar.resignFirstResponder()
    }
}
