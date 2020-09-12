//
//  Occupancy.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/17/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

enum OccupancyStatus {
    case high
    case medium
    case low
    
    func badge() -> TagView {
        let badge = TagView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.widthAnchor.constraint(equalToConstant: 50).isActive = true
        switch self {
        case OccupancyStatus.high:
            badge.text = "High"
            badge.backgroundColor = Color.highOccupancyTag
        case OccupancyStatus.medium:
            badge.text = "Medium"
            badge.backgroundColor = Color.medOccupancyTag
        case OccupancyStatus.low:
            badge.text = "Low"
            badge.backgroundColor = Color.lowOccupancyTag
        }
        return badge
    }
}

// Object containing occupancy data for a location based on day of week and hour of day.
class Occupancy {
    // dictionary mapping day of week and hour of day to a percent occupancy
    var dailyOccupancy: [DayOfWeek: [Int: Int]]
    // percent occupancy for the current time
    var liveOccupancy: Int?
    // ranges for what percentage constitutes each status (high, medium, low)
    static let statusBounds: [OccupancyStatus: ClosedRange<Int>] = [OccupancyStatus.high: 70...100, OccupancyStatus.medium: 30...69, OccupancyStatus.low: 0...29]
    
    init(dailyOccupancy: [DayOfWeek: [Int: Int]], live: Int?) {
        self.dailyOccupancy = dailyOccupancy
        self.liveOccupancy = live
    }
    
    // get a percent occupancy for the current date, with live data taking priority
    func getCurrentOccupancyPercent() -> Int? {
        if let live = liveOccupancy {
            return live
        }
        return getHistoricOccupancyPercent(date: Date())
    }
    
    // get a percent occupancy based on a date object (current day and time)
    func getHistoricOccupancyPercent(date: Date) -> Int? {
        let day = DayOfWeek.weekday(date)
        let hour = Calendar.current.component(.hour, from: date)
        if let forDay = dailyOccupancy[day] {
            return forDay[hour] ?? nil
        }
        return nil
    }
    
    // get a status (high, medium, low) for the current date, with live data taking priority
    func getCurrentOccupancyStatus() -> OccupancyStatus? {
        return occupancyStatusFrom(percent: getCurrentOccupancyPercent())
    }
    
    // get a status (high, medium, low) based on a date object
    func getHistoricOccupancyStatus(date: Date) -> OccupancyStatus? {
        return occupancyStatusFrom(percent: getHistoricOccupancyPercent(date: date))
    }
    
    private func occupancyStatusFrom(percent: Int?) -> OccupancyStatus? {
        if percent == nil {
            return nil
        }
        if Occupancy.statusBounds[OccupancyStatus.high]!.contains(percent!) {
            return OccupancyStatus.high
        } else if Occupancy.statusBounds[OccupancyStatus.medium]!.contains(percent!) {
            return OccupancyStatus.medium
        } else if Occupancy.statusBounds[OccupancyStatus.low]!.contains(percent!) {
            return OccupancyStatus.low
        } else {
            return nil
        }
    }
    
    // get occupancy dictionary for one day of the week
    func occupancy(for day: DayOfWeek) -> [Int: Int]? {
        return dailyOccupancy[day]
    }
}
