//
//  ChatViewController.swift
//  LittleQuery
//
//  Created by 한유진 on 4/8/24.
//

import UIKit
import Alamofire

class ChatViewController: UIViewController {
    var apiKey = AppConfig.apiKeyChat
    var messages: [Message] = [Message(role: "system", content: "You are a biology research assistant. Please provide concise responses, between 1 to 3 sentences.")]
    var messageCount = 0 {
        didSet {
            sendMessage()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func sendMessage() {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let params: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        
        AF.request(
            "https://api.openai.com/v1/chat/completions",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: ChatRoot.self) { response in
            switch response.result {
            case .success(let root):
                guard let content = root.choices.first?.message.content else { return }
                self.messages.append(Message(role: "assistant", content: content))
                self.tableView.reloadData()
                
                let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
                if lastRowIndex >= 0 {
                    let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
                    self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let text = textView.text, !text.isEmpty {
            messages.append(Message(role: "user", content: text))
            tableView.reloadData()
            textView.text = ""
            messageCount += 2
            let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
            if lastRowIndex >= 0 {
                let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
                tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String = messages[indexPath.row + 1].role == "user" ? "messageSent" : "messageReceived"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    
        let label = cell.viewWithTag(100) as? UILabel
        label?.text = messages[indexPath.row + 1].content
        
        return cell
    }
}
