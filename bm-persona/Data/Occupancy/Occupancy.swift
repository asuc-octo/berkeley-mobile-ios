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
}

// Object containing occupancy data for a location based on day of week and hour of day.
class Occupancy {
    
    // dictionary mapping day of week and hour of day to a percent occupancy
    var dailyOccupancy: [DayOfWeek: [Int: Int]]
    // ranges for what percentage constitutes each status (high, medium, low)
    static let statusBounds: [OccupancyStatus: ClosedRange<Int>] = [OccupancyStatus.high: 70...100, OccupancyStatus.medium: 30...69, OccupancyStatus.low: 0...29]
    //nice
    
    init(dailyOccupancy: [DayOfWeek: [Int: Int]]) {
        self.dailyOccupancy = dailyOccupancy
    }
    
    // get a percent occupancy based on a date object (current day and time)
    func getOccupancyPercent(date: Date) -> Int? {
        let day = DayOfWeek.weekday(date)
        let hour = Calendar.current.component(.hour, from: date)
        if let forDay = dailyOccupancy[day] {
            return forDay[hour] ?? nil
        }
        return nil
    }
    
    // get a status (high, medium, low) based on a date object
    func getOccupancyStatus(date: Date) -> OccupancyStatus? {
        let percent = getOccupancyPercent(date: date)
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

}
