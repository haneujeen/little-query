//
//  MiniTableManager.swift
//  LittleQuery
//
//  Created by 한유진 on 4/12/24.
//

import UIKit

class MiniTableManager: NSObject, UITableViewDelegate, UITableViewDataSource {
//    var data: [String]
//    
//    init(data: [String]) {
//        self.data = data
//        super.init()
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mini", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = "Row \(indexPath.row)"
        config.secondaryText = "The quick brown fox jumps over the lazy dog."
        cell.contentConfiguration = config
        
        return cell
    }
}
