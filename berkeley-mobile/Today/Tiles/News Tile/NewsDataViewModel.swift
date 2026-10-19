//
//  NewsDataViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/6/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FirebaseFirestore
import Foundation
import Observation
import os

@MainActor
@Observable
class NewsDataViewModel {
    var newsArticles: [NewsArticle] = []
    var showNotAvailable = false

    @ObservationIgnored
    private let db = Firestore.firestore()
    @ObservationIgnored
    private let kNewsDataEndpoint = "Daily Cal News"

    init() {
        Task {
            newsArticles = await fetchNewsArticles()
            showNotAvailable = newsArticles.isEmpty
        }
    }

    @concurrent
    func fetchNewsArticles() async -> [NewsArticle] {
        guard let snap = try? await db.collection(kNewsDataEndpoint).getDocuments() else {
            return []
        }

        var newsArticles: [NewsArticle] = []
        for doc in snap.documents {
            do {
                newsArticles.append(try doc.data(as: NewsArticle.self))
            } catch {
                Logger.newsDataViewModel.error("Unable to decode newsarticle: \(error)")
            }
        }
        Logger.newsDataViewModel.info("Successfully decoded \(newsArticles.count) news articles")
        return newsArticles
    }
}
