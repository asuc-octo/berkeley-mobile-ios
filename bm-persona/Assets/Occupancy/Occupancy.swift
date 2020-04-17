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

class Occupancy {

    var dailyOccupancy: [DayOfWeek: [Int: Int]]
    static let statusBounds: [OccupancyStatus: ClosedRange<Int>] = [OccupancyStatus.high: 70...100, OccupancyStatus.medium: 30...69, OccupancyStatus.low: 0...29]
    //nice
    
    init(dailyOccupancy: [DayOfWeek: [Int: Int]]) {
        self.dailyOccupancy = dailyOccupancy
    }
    
    func getOccupancyPercent(date: Date) -> Int? {
        let day = DayOfWeek.weekday(date)
        let hour = Calendar.current.component(.hour, from: date)
        if let forDay = dailyOccupancy[day] {
            return forDay[hour] ?? nil
        }
        return nil
    }
    
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
