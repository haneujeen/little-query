//
//  Article.swift
//  LittleQuery
//
//  Created by 한유진 on 4/9/24.
//

/** Sample response
 "organic_results": [
     {
         "position": 0,
         "title": "A new biology for a new century",
         "result_id": "KNJ0p4CbwgoJ",
         "link": "https://journals.asm.org/doi/abs/10.1128/mmbr.68.2.173-186.2004",
         "snippet": "… molecular biology's lead … in biology that 20th century biology, molecular biology, could not handle and, so, avoided. The former course, though highly productive, is certain to turn biology …",
         "publication_info": {
            "summary": "CR Woese - Microbiology and molecular biology reviews, 2004 - Am Soc Microbiol"
         }
    }
 ],
 "pagination": {
     "current": 1
 }
 */

import Foundation

struct Article: Codable {
    let index: Int
    let title: String
    let link: String
    let snippet: String
    let publication: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case index = "position"
        case title
        case link
        case snippet
        case publication = "publication_info"
    }
}

struct Pagination: Codable {
    let current: Int
}

struct Root: Codable {
    let results: [Article]
    let pagination: Pagination
    
    enum CodingKeys: String, CodingKey {
        case results = "organic_results"
        case pagination
    }
}
