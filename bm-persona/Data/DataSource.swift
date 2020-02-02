//
//  DataSource.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation

protocol DataSource {
    typealias completionHandler = (_ resources: [Any]) -> Void
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    
    static func parseWeeklyTimes(_ times: [[String: Any]]?) -> [DateInterval?]
}

fileprivate let kOpenKey = "open_time"
fileprivate let kCloseKey = "close_time"

extension DataSource {
    
    // Parses the dictionary for a length 7 array of DateIntervals
    static func parseWeeklyTimes(_ times: [[String: Any]]?) -> [DateInterval?] {
        var parsedIntervals = [DateInterval?](repeating: nil, count: 7)
        guard let times = times else {
            return parsedIntervals
        }
        for open_close in times {
            if let open = open_close[kOpenKey] as? Double,
               let close = open_close[kCloseKey] as? Double,
               let openDate = Date(timeIntervalSince1970: open).sameDayThisWeek(),
               var closeDate = Date(timeIntervalSince1970: close).sameDayThisWeek() {
                if openDate > closeDate {
                    let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: closeDate)
                    closeDate = Calendar.current.nextDate(after: openDate, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? Date.distantPast
                }
                if openDate <= closeDate {
                    let interval = DateInterval(start: openDate, end: closeDate)
                    parsedIntervals[openDate.weekday()] = interval
                }
            }
        }
        return parsedIntervals
    }
}
