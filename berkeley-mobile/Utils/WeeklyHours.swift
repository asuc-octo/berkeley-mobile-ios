//
//  WeeklyHours.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/17/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

/**
    DateIntervals are adjusted to the current week, and may extend to the next day. Items are sorted.
    `DateInterval.duration = 0` for 24-hour services.
*/
typealias DailyHoursType = [HoursInterval]

/** Maps DayOfWeek to array of disjoint open hours. */
typealias WeeklyHoursType = [DayOfWeek: DailyHoursType]

/** Wrapper for the `WeeklyHoursType` dictionary. */
class WeeklyHours {
    
    private var weeklyHours: WeeklyHoursType

    /// Boolean indicating if the object contains no intervals.
    open var isEmpty: Bool {
        return weeklyHours.isEmpty
    }
    
    init() {
        self.weeklyHours = [:]
    }
    
    init(weeklyHours: WeeklyHoursType) {
        self.weeklyHours = weeklyHours
    }
    
    public func hoursForWeekday(_ weekday: DayOfWeek) -> DailyHoursType {
        return weeklyHours[weekday, default: []]
    }
    
    public func setHoursForWeekday(_ weekday: DayOfWeek, hours: DailyHoursType) {
        weeklyHours[weekday] = hours.sorted()
    }
    
    public func addInterval(_ interval: HoursInterval, to weekday: DayOfWeek) {
        var hours = hoursForWeekday(weekday)
        hours.append(interval)
        setHoursForWeekday(weekday, hours: hours)
    }
    
}

struct HoursInterval: Comparable, Equatable {

    var note: String?
    var dateInterval: DateInterval
    
    static func < (lhs: HoursInterval, rhs: HoursInterval) -> Bool {
        return lhs.dateInterval < rhs.dateInterval
    }
    
    static func > (lhs: HoursInterval, rhs: HoursInterval) -> Bool {
        return lhs.dateInterval > rhs.dateInterval
    }
    
    static func == (lhs: HoursInterval, rhs: HoursInterval) -> Bool {
        return lhs.dateInterval == rhs.dateInterval
    }

    func contains(_ date: Date) -> Bool {
        return self.dateInterval.contains(date)
    }
    
}
