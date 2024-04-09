//
//  GoogleScholarTableViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit

class GoogleScholarTableViewController: UITableViewController {
    let apiKey = "3e0d360330ffda3410e04ebabbdcae1068124e880e5fcbb3b2c75ba385d4e0e7"
    var results: [Article]?
    
    func buildRequest(query: String, page: Int, size: Int) -> URLRequest {
        let endpoint = "https://serpapi.com/search?engine=google_scholar&q=\(query)&hl=en&start=\(page)&api_key=\(apiKey)&num=\(size)"
        
        guard let endpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: endpoint)
        else { fatalError() }
        
        return URLRequest(url: url)
    }
    
    func createTask(query: String?, page: Int, size: Int) {
        guard let query else { return }
        let request = buildRequest(query: query, page: page, size: size)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error { print(error.localizedDescription); return }
            
            guard let data else { return }
            
            let root = try? JSONDecoder().decode(Root.self, from: data)
            self.results = root?.results
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        createTask(query: "biology", page: 0, size: 5)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)

        // Configure the cell...
        let titleLabel = cell.viewWithTag(1) as? UILabel
        titleLabel?.text = results?[indexPath.row].title
        let publicationLabel = cell.viewWithTag(2) as? UILabel
        publicationLabel?.text = results?[indexPath.row].publication["summary"]
        let snippetLabel = cell.viewWithTag(3) as? UILabel
        snippetLabel?.text = results?[indexPath.row].snippet

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "articleSegue" {
            let controller = segue.destination as? GSDetailViewController
        }
    }

}
