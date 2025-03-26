//
//  DayOfWeek.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/16/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

enum DayOfWeek: Int, CaseIterable, CustomStringConvertible {
    
    case sunday    = 0
    case monday    = 1
    case tuesday   = 2
    case wednesday = 3
    case thursday  = 4
    case friday    = 5
    case saturday  = 6
    
    var description: String {
        return stringRepresentation()
    }
    
    static var allDayNames: [String] {
        return DayOfWeek.allCases.map { $0.description }
    }
    
    static func weekday(_ date: Date) -> DayOfWeek {
        return DayOfWeek(rawValue: date.weekday())!
    }
    
    func adding(num: Int) -> DayOfWeek {
        return DayOfWeek(rawValue: (rawValue + num) % 7)!
    }
    
    func stringRepresentation(includesYesterdayTodayVerbage: Bool = false) -> String {
        if includesYesterdayTodayVerbage {
            let weekdayNum = Date().weekday()
            
            if weekdayNum % 7 == rawValue {
                return "Today"
            }
            
            if (weekdayNum - 1) % 7 == rawValue {
                return "Yesterday"
            }
        }

        switch self {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        }
    }
    
    func charRepresentation() -> String {
        switch self {
        case .sunday:
            return "S"
        case .monday:
            return "M"
        case .tuesday:
            return "T"
        case .wednesday:
            return "W"
        case .thursday:
            return "T"
        case .friday:
            return "F"
        case .saturday:
            return "S"
        }
    }
    
}
