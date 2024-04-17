//
//  AppConfig.swift
//  LittleQuery
//
//  Created by 한유진 on 4/17/24.
//

import Foundation

struct AppConfig {
    static let apiKeyGoogleScholar = ProcessInfo.processInfo.environment["apiKeyGoogleScholar"] ?? ""
    static let apiKeyYoutubeData = ProcessInfo.processInfo.environment["apiKeyYoutubeData"] ?? ""
    static let apiKeyChat = ProcessInfo.processInfo.environment["apiKeyChat"] ?? ""
}
