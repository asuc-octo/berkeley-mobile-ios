

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

extension ResourceDataSource {
    
    // Parses the dictionary for a length 7 array of DateIntervals
    static func parseWeeklyTimes(_ times: [[String: Any]], openKey: String, closeKey: String) -> [DateInterval?] {
        var parsedIntervals = [DateInterval?](repeating: nil, count: 7)
        for open_close in times {
            if let open = open_close[openKey] as? Double,
               let close = open_close[closeKey] as? Double,
               let openDate = Date(timeIntervalSince1970: open).sameDayThisWeek(),
               let closeDate = Date(timeIntervalSince1970: close).sameDayThisWeek() {
                let weekday = openDate.weekday()
                if openDate <= closeDate {
                    let interval = DateInterval(start: openDate, end: closeDate)
                    parsedIntervals[weekday] = interval
                }
            }
        }
        return parsedIntervals
    }
}
