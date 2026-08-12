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
    func nextOpenInterval() -> HoursInterval?
    
}

extension HasOpenTimes {
    
    static func parseWeeklyHours(dict: [[String: Any]]?, openKey: String = "open_time", closeKey: String = "close_time", notesKey: String = "notes") -> WeeklyHours? {
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
                    let interval = HoursInterval(
                        note: open_close[notesKey] as? String,
                        dateInterval: DateInterval(start: openDate, end: closeDate)
                    )
                    weeklyHours.addInterval(interval, to: DayOfWeek.weekday(openDate))
                    
                }
            }
        }
        return weeklyHours.isEmpty ? nil : weeklyHours
    }
    
    /// Intervals are filed under the weekday they start on and may run past midnight, so an
    /// interval opened yesterday can still be the one covering `date`.
    private func intervalsCovering(_ date: Date, in weeklyHours: WeeklyHours) -> DailyHoursType {
        let today = DayOfWeek.weekday(date)
        let yesterday = today.adding(num: 6)
        return weeklyHours.hoursForWeekday(yesterday) + weeklyHours.hoursForWeekday(today)
    }

    var isOpen: Bool? {
        guard let weeklyHours = weeklyHours else { return nil }
        let now = Date()
        let intervals = intervalsCovering(now, in: weeklyHours)
        return intervals.contains { interval in
            interval.contains(now)
        }
    }
    
    // The current or next open interval for the day
    func nextOpenInterval() -> HoursInterval? {
        guard let weeklyHours = self.weeklyHours else { return nil }
        let date = Date()
        let intervals = intervalsCovering(date, in: weeklyHours)
        var nextOpenInterval: HoursInterval?
        for interval in intervals {
            if interval.contains(date) {
                nextOpenInterval = interval
                break
            } else if date.compare(interval.dateInterval.start) == .orderedAscending && interval.dateInterval.duration > 0 {
                if nextOpenInterval == nil {
                    nextOpenInterval = interval
                } else if interval < nextOpenInterval! {
                    nextOpenInterval = interval
                }
            }
        }
        return nextOpenInterval
    }
}
