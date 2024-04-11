//
//  YouTubePlayerViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/11/24.
//

import UIKit
import YouTubeiOSPlayerHelper

class YouTubePlayerViewController: UIViewController {
    var videoId: String?
    @IBOutlet weak var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let videoId else { return }
        playerView.load(withVideoId: videoId)
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
