//
//  App.swift
//  AppStoreClone
//
//  Created by Pradeep Gianchandani on 14/05/21.
//

import Foundation

struct AppGroup: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let title: String
    let results: [FeedResult]
}

struct FeedResult: Decodable {
    let name, artistName, artworkUrl100: String
}
