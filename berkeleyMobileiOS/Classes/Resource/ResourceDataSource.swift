

/**
 * `ResourceDataSource` implements a static function that fetches 
 * list of `ResourceTypes` and returns the results to the completion handler.
 */
import SwiftyJSON

protocol ResourceDataSource
{
    typealias completionHandler = (_ resources: [Resource]?) -> Void

    static func fetchResources(_ completion: @escaping completionHandler)
    static func parseResource(_ json: JSON) -> Resource
}

fileprivate let kOpenKey = "open_time"
fileprivate let kCloseKey = "close_time"

extension ResourceDataSource {
    
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
