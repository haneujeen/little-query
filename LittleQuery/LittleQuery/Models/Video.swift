//
//  Video.swift
//  LittleQuery
//
//  Created by 한유진 on 4/9/24.
//

import Foundation

struct ThumbnailSizes: Codable {
    let medium: Thumbnail
    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
}

struct Snippet: Codable {
    let publishedAt: String
    let title: String
    let thumbnails: ThumbnailSizes
    let channelTitle: String
}

struct Id: Codable {
    let videoId: String
}

struct Video: Codable {
    let snippet: Snippet
    let id: Id
}

struct YoutubeRoot: Codable {
    let items: [Video]
}
