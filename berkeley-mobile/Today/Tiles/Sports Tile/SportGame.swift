//
//  SportGame.swift
//  berkeley-mobile
//
//  Created by ASUC OCTO on 7/28/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import Foundation

struct SportGame: Codable, Identifiable {
    var id: String
    var sport: String
    var homeTeam: String
    var awayTeam: String
    var homeScore: Int?
    var awayScore: Int?
    var gameDate: Date?
    var location: String?
    var status: SportGameStatus
    var logoURL: String?

    enum SportGameStatus: String, Codable {
        case upcoming
        case inProgress = "in_progress"
        case final_ = "final"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case sport
        case homeTeam
        case awayTeam
        case homeScore
        case awayScore
        case gameDate
        case location
        case status
        case logoURL = "logoUrl"
    }
}
