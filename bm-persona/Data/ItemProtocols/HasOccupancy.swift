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
    func getCurrentOccupancyPercent() -> Int? {
        return occupancy?.getCurrentOccupancyPercent()
    }
    
    func getHistoricOccupancyPercent(date: Date) -> Int? {
        return occupancy?.getHistoricOccupancyPercent(date: date)
    }
    
    func getCurrentOccupancyStatus(isOpen: Bool?) -> OccupancyStatus? {
        if let isOpen = isOpen, !isOpen {
            return nil
        }
        return occupancy?.getCurrentOccupancyStatus()
    }
    
    func getHistoricOccupancyStatus(date: Date, isOpen: Bool?) -> OccupancyStatus? {
        if let isOpen = isOpen, !isOpen {
            return nil
        }
        return occupancy?.getHistoricOccupancyStatus(date: date)
    }
}
