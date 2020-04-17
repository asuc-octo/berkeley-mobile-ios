//
//  HasOccupancy.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/17/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

protocol HasOccupancy {
    var occupancy: Occupancy? { get set }
}

extension HasOccupancy {
    func getOccupancyPercent(date: Date) -> Int? {
        if occupancy != nil {
            return occupancy!.getOccupancyPercent(date: date)
        } else {
            return nil
        }
    }
    
    func getOccupancyStatus(date: Date) -> OccupancyStatus? {
        if occupancy != nil {
            return occupancy!.getOccupancyStatus(date: date)
        } else {
            return nil
        }
    }
}
