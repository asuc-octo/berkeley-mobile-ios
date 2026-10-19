//
//  NewsArticle.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/11/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import Foundation

struct NewsArticle: Codable {
    var article: NewsArticleContent
    var scrapedAt: Date
}

struct NewsArticleContent: Codable {
    var description: String?
    var imageURL: String?
    var articleURL: String?
    var lastUploaded: String?
    var title: String?

    enum CodingKeys: String, CodingKey {
        case imageURL = "imageUrl"
        case articleURL = "url"

        case description
        case lastUploaded
        case title
    }
}
