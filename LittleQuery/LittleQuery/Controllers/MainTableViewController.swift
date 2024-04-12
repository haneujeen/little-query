//
//  MainTableViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/12/24.
//

import UIKit

class MainTableViewController: UITableViewController {
    var query: String?
    var engines = ["Google Scholar", "YouTube", "ChatGPT"]
    @IBOutlet weak var searchBar: UISearchBar!
    var searchDebounceTimer: Timer?
    
    // Flags
    var isFetching = false
    
    // Mini tables
    var miniTableManagers: [Int: MiniTableManager] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        searchBar.delegate = self
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "toGoogleScholar", sender: self)
            case 1:
                performSegue(withIdentifier: "toYoutube", sender: self)
            case 2:
                performSegue(withIdentifier: "toChat", sender: self)
            default:
                break
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath)
            cell.selectionStyle = .none
            let engineLabel = cell.viewWithTag(1) as? UILabel
            engineLabel?.text = engines[indexPath.row]
            
            let promptLabel = cell.viewWithTag(2) as? UILabel
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
            cell.selectionStyle = .none
            // Default configuration
            let engineLabel = cell.viewWithTag(1) as? UILabel
            engineLabel?.text = engines[indexPath.row]
                
            let miniTable = cell.viewWithTag(3) as? UITableView
            
            let manager = miniTableManagers[indexPath.row] ?? MiniTableManager()
            miniTableManagers[indexPath.row] = manager
            
            miniTable?.delegate = manager
            miniTable?.dataSource = manager
            miniTable?.register(UITableViewCell.self, forCellReuseIdentifier: "mini")
            miniTable?.reloadData()
            
            return cell
        }
    }
    
    // MARK: - TableView Delegate Implementation
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2: return 150
        default: return 210
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] _ in
            self?.query = searchText
            print(self?.query)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
