//
//  HasCapacity.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import MapKit

protocol HasWeeklyHours {
    
    var isOpen: Bool { get }
    var weeklyHours: [DateInterval?] { get }
    
}

extension HasWeeklyHours {
    var isOpen: Bool {
        if self.weeklyHours.count == 0 {
            return false
        }
        var status = false
        if let interval = self.weeklyHours[Date().weekday()] {
            if interval.contains(Date()) || interval.duration == 0 {
                status = true
            }
        }
        return status
    }
}
