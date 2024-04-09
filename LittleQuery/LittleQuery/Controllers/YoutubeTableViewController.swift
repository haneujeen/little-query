//
//  YoutubeTableViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit
import Alamofire
import Kingfisher

class YoutubeTableViewController: UITableViewController {
    var videos: [Video]?
    
    func search(query: String?) {
        guard let query else { return }
        let endpoint = "https://www.googleapis.com/youtube/v3/search"
        let params: Parameters = [
            "part": "snippet",
            "maxResults": 1,
            "q": query,
            "topicId": "/m/01k8wb",
            "type": "video",
            "videoCategoryId": 28,
            "key": apiKey
        ]
        let alamo = AF.request(endpoint, method: .get, parameters: params)
        
        alamo.responseDecodable(of: YoutubeRoot.self) { response in
            switch response.result {
            case .success(let root):
                self.videos = root.items
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        search(query: "boating%7Csailing -fishing")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videos?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "video", for: indexPath)
        guard let video = videos?[indexPath.row] else { return cell }

        // Configure the cell...
        let thumbnailImage = cell.viewWithTag(1) as? UIImageView
        thumbnailImage?.kf.setImage(with: URL(string: video.snippet.thumbnails.medium.url))
        
        let titleLabel = cell.viewWithTag(2) as? UILabel
        titleLabel?.text = video.snippet.title

        let channelTitleLabel = cell.viewWithTag(3) as? UILabel
        channelTitleLabel?.text = video.snippet.channelTitle

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
