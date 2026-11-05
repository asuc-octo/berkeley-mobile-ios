//
//  SportsDataViewModel.swift
//  berkeley-mobile
//
//  Created by ASUC OCTO on 7/28/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FirebaseFirestore
import Foundation
import Observation
import os

@MainActor
@Observable
class SportsDataViewModel {
    var games: [SportGame] = []
    var showNotAvailable = false

    @ObservationIgnored
    private let db = Firestore.firestore()
    @ObservationIgnored
    private let kSportsDataEndpoint = "Berkeley Sports"

    init() {
        Task {
            games = await fetchGames()
            showNotAvailable = games.isEmpty
        }
    }

    @concurrent
    func fetchGames() async -> [SportGame] {
        guard let snap = try? await db.collection(kSportsDataEndpoint).getDocuments() else {
            return []
        }

        var games: [SportGame] = []
        for doc in snap.documents {
            do {
                games.append(try doc.data(as: SportGame.self))
            } catch {
                Logger.sportsDataViewModel.error("Unable to decode sport game: \(error)")
            }
        }
        Logger.sportsDataViewModel.info("Successfully decoded \(games.count) sport games")
        return games
    }
}
