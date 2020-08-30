//
//  HasOccupancy.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/17/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

// protocol for objects that have occupancy data
protocol HasOccupancy {
    var occupancy: Occupancy? { get set }
}

extension HasOccupancy {
    func getOccupancyPercent(date: Date) -> Int? {
        return occupancy?.getOccupancyPercent(date: date)
    }
    
    func getOccupancyStatus(date: Date, isOpen: Bool?) -> OccupancyStatus? {
        if let isOpen = isOpen, !isOpen {
            return nil
        }
        return occupancy?.getOccupancyStatus(date: date)
    }
}
