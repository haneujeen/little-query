//
//  GSDetailViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit
import WebKit

class GSDetailViewController: UIViewController {
    var url: URL?
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let url else { return }
        webView.load(URLRequest(url: url))
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
