//
//  MiniTableManager.swift
//  LittleQuery
//
//  Created by 한유진 on 4/12/24.
//

import UIKit
import Kingfisher

enum Engine {
    case GoogleScholar
    case YouTube
}

class MiniTableManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    var articles: [Article]?
    var videos: [Video]?
    var engine: Engine
    
    init(engine: Engine, articles: [Article]? = nil, videos: [Video]? = nil) {
        self.articles = articles
        self.videos = videos
        self.engine = engine
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch engine {
        case .GoogleScholar: return articles?.count ?? 0
        case .YouTube: return videos?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if engine == .GoogleScholar {
            let cell = tableView.dequeueReusableCell(withIdentifier: "miniArticle", for: indexPath)
            guard let article = articles?[indexPath.row] else { return cell }
            
            // Configure the cell...
            let titleLabel = cell.viewWithTag(1) as? UILabel
            titleLabel?.text = article.title
            
            let publicationLabel = cell.viewWithTag(2) as? UILabel
            publicationLabel?.text = article.publication.summary
            
            let snippetLabel = cell.viewWithTag(3) as? UILabel
            snippetLabel?.text = article.snippet
            
            return cell
        } else { // engine == .YouTube
            let cell = tableView.dequeueReusableCell(withIdentifier: "miniVideo", for: indexPath)
            guard let video = videos?[indexPath.row] else { return cell }
            
            // Configure the cell...
            let thumbnailImage = cell.viewWithTag(1) as? UIImageView
            thumbnailImage?.kf.setImage(with: URL(string: video.snippet.thumbnails.medium.url))
            thumbnailImage?.contentMode = .scaleAspectFill
            
            let titleLabel = cell.viewWithTag(2) as? UILabel
            titleLabel?.text = video.snippet.title

            let channelTitleLabel = cell.viewWithTag(3) as? UILabel
            channelTitleLabel?.text = video.snippet.channelTitle
            
            return cell
        }
    }
}
