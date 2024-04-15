//
//  ChatViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit

class ChatViewController: UIViewController {
    var messages: [Message] = [Message(role: "system", content: "You are a biology research assistant.")]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let text = textView.text, !text.isEmpty {
            messages.append(Message(role: "user", content: text))
            //tableView.reloadData()
            textView.text = ""
            //tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = messages[indexPath.row].role == "user" ? "messageSent" : "messageReceived"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    
        let label = cell.viewWithTag(100) as? UILabel
        label?.text = messages[indexPath.row].content
        
        return cell
    }
}
