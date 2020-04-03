//
//  DayOfWeek.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/16/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

enum DayOfWeek: Int, CaseIterable {
    
    case sunday    = 0
    case monday    = 1
    case tuesday   = 2
    case wednesday = 3
    case thursday  = 4
    case friday    = 5
    case saturday  = 6
    
    static func weekday(_ date: Date) -> DayOfWeek {
        return DayOfWeek(rawValue: date.weekday())!
    }
    
    func adding(num: Int) -> DayOfWeek {
        return DayOfWeek(rawValue: (self.rawValue + num) % 7)!
    }
    
}
