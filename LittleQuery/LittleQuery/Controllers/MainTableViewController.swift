//
//  MainTableViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/12/24.
//

import UIKit

class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
            cell.backgroundColor = UIColor.systemPink
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
            cell.backgroundColor = UIColor.green
            // Default configuration
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
