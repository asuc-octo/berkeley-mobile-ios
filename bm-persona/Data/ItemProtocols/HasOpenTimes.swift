//
//  HasOpenTimes.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

protocol HasOpenTimes {
    
    var weeklyHours: WeeklyHours? { get }
    func nextOpenInterval() -> DateInterval?
    
}

extension HasOpenTimes {
    
    static func parseWeeklyHours(dict: [[String: Any]]?, openKey: String = "open_time", closeKey: String = "close_time") -> WeeklyHours? {
        guard let times = dict else { return nil }
        let weeklyHours = WeeklyHours()
        for open_close in times {
            if let open = open_close[openKey] as? Double,
                let close = open_close[closeKey] as? Double,
               let openDate = Date(timeIntervalSince1970: open).sameDayThisWeek(),
               var closeDate = Date(timeIntervalSince1970: close).sameDayThisWeek() {
                if openDate > closeDate {
                    let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: closeDate)
                    closeDate = Calendar.current.nextDate(after: openDate, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? Date.distantPast
                }
                if openDate <= closeDate {
                    let interval = DateInterval(start: openDate, end: closeDate)
                    weeklyHours.addInterval(interval, to: DayOfWeek.weekday(openDate))
                }
            }
        }
        return weeklyHours
    }
    
    // TODO: Fixme, Dining halls may have open/close times that overlap multiple days.
    var isOpen: Bool? {
        guard let weeklyHours = weeklyHours else { return nil }
        let now = Date()
        let today = DayOfWeek.weekday(now)
        let intervals = weeklyHours.hoursForWeekday(today)
        return intervals.contains { interval in
            interval.contains(now) || interval.duration == 0
        }
    }
    
    // The current or next open interval for the day
    func nextOpenInterval() -> DateInterval? {
        guard let weeklyHours = self.weeklyHours else { return nil }
        let date = Date()
        let intervals = weeklyHours.hoursForWeekday(DayOfWeek.weekday(date))
        var nextOpenInterval: DateInterval?
        for interval in intervals {
            if interval.contains(date) {
                nextOpenInterval = interval
                break
            } else if date.compare(interval.start) == .orderedAscending {
                if nextOpenInterval == nil {
                    nextOpenInterval = interval
                } else if interval.compare(nextOpenInterval!) == .orderedAscending {
                    nextOpenInterval = interval
                }
            }
        }
        return nextOpenInterval
    }
}
