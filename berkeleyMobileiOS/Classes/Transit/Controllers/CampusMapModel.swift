//
//  CampusMapModel.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 1/11/19.
//  Copyright © 2019 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CampusMapModel {
    var locations: [Location] = []
    var shortcutButtons: [UIButton] = []
    static var shortcutsAndIconNames: [(String, String)] = [
        ("Bus Stops", "bus-icon-1"),
        ("Printers", "printer-icon"),
        ("Water Fountains", "water-bottle-icon"),
        ("Mental Health Resources", "mental-health-icon"),
        ("Microwaves", "microwave-icon"),
        ("Nap Pods", "nap-pods-icon"),
        ("Ford Go Bikes", "bike-icon")
    ]
    
    static var shortcutToIconNames: [String: String] = [
        "Bus Stop": "bus-icon-1",
        "Printer": "printer-icon",
        "Water Fountain": "water-bottle-icon",
        "Mental Health Resource": "mental-health-icon",
        "Microwave": "microwave-icon",
        "Nap Pod": "nap-pods-icon",
        "Ford Go Bike": "bike-icon"
    ]
    
    
    func search(for query: String) -> [Location] {
        if query == "Bus Stops" {
            return populateBusStops()
        } else {
            let formattedQuery = CampusMapModel.formatQuery(string: query)
            if CampusMapDataSource.completedFetchingLocations {
                if let locations =  CampusMapDataSource.queriesToLocations[formattedQuery] {
                    return locations
                }
            }
            return []
        }
    }
    
    static func formatQuery(string: String) -> String {
        let formatted = string.lowercased()
        return formatted
    }
}

class Location: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: String
    var numAttributes: Int = 3
    
    var moreInfo: String? = nil
    var notes: String? = nil
    var open_close_array: [Any]? = nil
    var phone: String? =  nil
    
    init(title: String, subtitle: String, coordinates: (Double, Double)) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: coordinates.0, longitude: coordinates.1)
        self.type = subtitle
    }
    
    func isOpen() -> (Bool, String)? {
        if let openTimes = open_close_array {
            let now = Date()
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.setLocalizedDateFormatFromTemplate("h:mma EEE")
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            timeFormatter.setLocalizedDateFormatFromTemplate("h:mma")
            let maxOpen: Date = Date(timeIntervalSince1970: CLTimeIntervalMax)
            var closestOpen: Date = maxOpen
            
            for interval in openTimes {
                if let interval = interval as? [String: Any?], let openTime = interval["open_time"] as? Int, let closeTime = interval["close_time"] as? Int {
                    let openDate = Date(timeIntervalSince1970: TimeInterval(openTime))
                    let closeDate = Date(timeIntervalSince1970: TimeInterval(closeTime))

                    if now.isBetween(openDate, closeDate) && closeDate < tomorrow {
                        return (true, "Closes \(timeFormatter.string(from: closeDate))")
                    }
                    
                    if openDate > now && openDate < closestOpen {
                        closestOpen = openDate
                    }
                }
            }
            
            if closestOpen == maxOpen {
                return (false, "")
            }
            
            return (false, "Opens \(dateFormatter.string(from: closestOpen))")
        }
        return nil
    }
}

var busSchedule: [String: [(String, String)]] = [:]
var busStops: [BusStop] = []

class BusStop: Location {
    var busLines: [String]
    var schedule: [String: [(String, String)]] = [
"H" : [],
"Perimeter" : [],
"Central Campus" : [],
"RFS" : []
]
    
    init(title: String, subtitle: String, coordinates: (Double, Double), busLines: [String]) {
        self.busLines = busLines
        super.init(title: title, subtitle: subtitle, coordinates: coordinates)
    }
    
    func nextTimeOnLine(line: String, direction: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        
        let calendar = Calendar.current
        let now = Date()
        let dateRef = dateFormatter.date(from: dateFormatter.string(from: now))
    
        if let data = schedule[line] {
            var closestTime = Date(timeIntervalSince1970: CLTimeIntervalMax)
            var closestTimeString = ""
            
            for item in data {
                if item.0 == direction {
                    let date = dateFormatter.date(from: item.1)!
                    
                    if date.isBetween(dateRef, closestTime) {
                        closestTime = date
                        closestTimeString = item.1
                    }
                    
                }
            }
            return closestTimeString
        }
        return ""
    }
}

let lineDirections = [
    "H" : ("Towards Lawrence Hall", "Towards Evans Hall"),
    "RFS" : ("Towards Downtown Berkeley", "Towards Richmond")
]

let hillLineTimes = [
    "7:40 AM",
    "7:45 AM",
    "7:47 AM",
    "7:49 AM",
    "7:51 AM",
    "7:55 AM",
    "7:57 AM",
    "7:59 AM",
    "8:01 AM",
    "8:05 AM",
    "8:10 AM",
    "8:15 AM",
    "8:17 AM",
    "8:19 AM",
    "8:21 AM",
    "8:25 AM",
    "8:27 AM",
    "8:29 AM",
    "8:31 AM",
    "8:35 AM",
    "8:40 AM",
    "8:45 AM",
    "8:47 AM",
    "8:49 AM",
    "8:51 AM",
    "8:55 AM",
    "8:57 AM",
    "8:59 AM",
    "9:01 AM",
    "9:05 AM",
    "9:10 AM",
    "9:15 AM",
    "9:17 AM",
    "9:19 AM",
    "9:21 AM",
    "9:25 AM",
    "9:27 AM",
    "9:29 AM",
    "9:31 AM",
    "9:35 AM",
    "9:40 AM",
    "9:45 AM",
    "9:47 AM",
    "9:49 AM",
    "9:51 AM",
    "9:55 AM",
    "9:57 AM",
    "9:59 AM",
    "10:01 AM",
    "10:05 AM",
    "10:10 AM",
    "10:15 AM",
    "10:17 AM",
    "10:19 AM",
    "10:21 AM",
    "10:25 AM",
    "10:27 AM",
    "10:29 AM",
    "10:31 AM",
    "10:35 AM",
    "10:40 AM",
    "10:45 AM",
    "10:47 AM",
    "10:49 AM",
    "10:51 AM",
    "10:55 AM",
    "10:57 AM",
    "10:59 AM",
    "11:01 AM",
    "11:05 AM",
    "11:10 AM",
    "11:15 AM",
    "11:17 AM",
    "11:19 AM",
    "11:21 AM",
    "11:25 AM",
    "11:27 AM",
    "11:29 AM",
    "11:31 AM",
    "11:35 AM",
    "11:40 AM",
    "11:45 AM",
    "11:47 AM",
    "11:49 AM",
    "11:51 AM",
    "11:55 AM",
    "11:57 AM",
    "11:59 AM",
    "12:01 PM",
    "12:05 PM",
    "12:10 PM",
    "12:15 PM",
    "12:17 PM",
    "12:19 PM",
    "12:21 PM",
    "12:25 PM",
    "12:27 PM",
    "12:29 PM",
    "12:31 PM",
    "12:35 PM",
    "12:40 PM",
    "12:45 PM",
    "12:47 PM",
    "12:49 PM",
    "12:51 PM",
    "12:55 PM",
    "12:57 PM",
    "12:59 PM",
    "1:01 PM",
    "1:05 PM",
    "1:10 PM",
    "1:15 PM",
    "1:17 PM",
    "1:19 PM",
    "1:21 PM",
    "1:25 PM",
    "1:27 PM",
    "1:29 PM",
    "1:31 PM",
    "1:35 PM",
    "1:40 PM",
    "1:45 PM",
    "1:47 PM",
    "1:49 PM",
    "1:51 PM",
    "1:55 PM",
    "1:57 PM",
    "1:59 PM",
    "2:01 PM",
    "2:05 PM",
    "2:10 PM",
    "2:15 PM",
    "2:17 PM",
    "2:19 PM",
    "2:21 PM",
    "2:25 PM",
    "2:27 PM",
    "2:29 PM",
    "2:31 PM",
    "2:35 PM",
    "2:40 PM",
    "2:45 PM",
    "2:47 PM",
    "2:49 PM",
    "2:51 PM",
    "2:55 PM",
    "2:57 PM",
    "2:59 PM",
    "3:01 PM",
    "3:05 PM",
    "3:10 PM",
    "3:15 PM",
    "3:17 PM",
    "3:19 PM",
    "3:21 PM",
    "3:25 PM",
    "3:27 PM",
    "3:29 PM",
    "3:31 PM",
    "3:35 PM",
    "3:40 PM",
    "3:45 PM",
    "3:47 PM",
    "3:49 PM",
    "3:51 PM",
    "3:55 PM",
    "3:57 PM",
    "3:59 PM",
    "4:01 PM",
    "4:05 PM",
    "4:10 PM",
    "4:15 PM",
    "4:17 PM",
    "4:19 PM",
    "4:21 PM",
    "4:25 PM",
    "4:27 PM",
    "4:29 PM",
    "4:31 PM",
    "4:35 PM",
    "4:40 PM",
    "4:45 PM",
    "4:47 PM",
    "4:49 PM",
    "4:51 PM",
    "4:55 PM",
    "4:57 PM",
    "4:59 PM",
    "5:01 PM",
    "5:05 PM",
    "5:10 PM",
    "5:15 PM",
    "5:17 PM",
    "5:19 PM",
    "5:21 PM",
    "5:25 PM",
    "5:27 PM",
    "5:29 PM",
    "5:31 PM",
    "5:35 PM",
    "5:40 PM",
    "5:45 PM",
    "5:47 PM",
    "5:49 PM",
    "5:51 PM",
    "5:55 PM",
    "5:57 PM",
    "5:59 PM",
    "6:01 PM",
    "6:05 PM",
    "6:10 PM",
    "6:15 PM",
    "6:17 PM",
    "6:19 PM",
    "6:21 PM",
    "6:25 PM",
    "6:27 PM",
    "6:29 PM",
    "6:31 PM",
    "6:35 PM",
    "7:00 PM",
    "7:05 PM",
    "7:07 PM",
    "7:09 PM",
    "7:11 PM",
    "7:15 PM",
    "7:17 PM",
    "7:19 PM",
    "7:21 PM",
    "7:25 PM"
]

let perimeterLineTimes = [
    "7:00 AM",
    "7:30 AM",
    "8:00 AM",
    "8:30 AM",
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
    "3:30 PM",
    "4:00 PM",
    "4:30 PM",
    "5:00 PM",
    "5:30 PM",
    "6:00 PM",
    "6:30 PM",
    "7:00 PM",
    "7:30 PM",
    "7:02 AM",
    "7:32 AM",
    "8:02 AM",
    "8:32 AM",
    "9:02 AM",
    "9:32 AM",
    "10:02 AM",
    "10:32 AM",
    "11:02 AM",
    "11:32 AM",
    "12:02 PM",
    "12:32 PM",
    "1:02 PM",
    "1:32 PM",
    "2:02 PM",
    "2:32 PM",
    "3:02 PM",
    "3:32 PM",
    "4:02 PM",
    "4:32 PM",
    "5:02 PM",
    "5:32 PM",
    "6:02 PM",
    "6:32 PM",
    "7:02 PM",
    "7:04 AM",
    "7:34 AM",
    "8:04 AM",
    "8:34 AM",
    "9:04 AM",
    "9:34 AM",
    "10:04 AM",
    "10:34 AM",
    "11:04 AM",
    "11:34 AM",
    "12:04 PM",
    "12:34 PM",
    "1:04 PM",
    "1:34 PM",
    "2:04 PM",
    "2:34 PM",
    "3:04 PM",
    "3:34 PM",
    "4:04 PM",
    "4:34 PM",
    "5:04 PM",
    "5:34 PM",
    "6:04 PM",
    "6:34 PM",
    "7:04 PM",
    "7:05 AM",
    "7:35 AM",
    "8:05 AM",
    "8:35 AM",
    "9:05 AM",
    "9:35 AM",
    "10:05 AM",
    "10:35 AM",
    "11:05 AM",
    "11:35 AM",
    "12:05 PM",
    "12:35 PM",
    "1:05 PM",
    "1:35 PM",
    "2:05 PM",
    "2:35 PM",
    "3:05 PM",
    "3:35 PM",
    "4:05 PM",
    "4:35 PM",
    "5:05 PM",
    "5:35 PM",
    "6:05 PM",
    "6:35 PM",
    "7:05 PM",
    "7:06 AM",
    "7:36 AM",
    "8:06 AM",
    "8:36 AM",
    "9:06 AM",
    "9:36 AM",
    "10:06 AM",
    "10:36 AM",
    "11:06 AM",
    "11:36 AM",
    "12:06 PM",
    "12:36 PM",
    "1:06 PM",
    "1:36 PM",
    "2:06 PM",
    "2:36 PM",
    "3:06 PM",
    "3:36 PM",
    "4:06 PM",
    "4:36 PM",
    "5:06 PM",
    "5:36 PM",
    "6:06 PM",
    "6:36 PM",
    "7:06 PM",
    "7:08 AM",
    "7:38 AM",
    "8:08 AM",
    "8:38 AM",
    "9:08 AM",
    "9:38 AM",
    "10:08 AM",
    "10:38 AM",
    "11:08 AM",
    "11:38 AM",
    "12:08 PM",
    "12:38 PM",
    "1:08 PM",
    "1:38 PM",
    "2:08 PM",
    "2:38 PM",
    "3:08 PM",
    "3:38 PM",
    "4:08 PM",
    "4:38 PM",
    "5:08 PM",
    "5:38 PM",
    "6:08 PM",
    "6:38 PM",
    "7:08 PM",
    "7:10 AM",
    "7:40 AM",
    "8:10 AM",
    "8:40 AM",
    "9:10 AM",
    "9:40 AM",
    "10:10 AM",
    "10:40 AM",
    "11:10 AM",
    "11:40 AM",
    "12:10 PM",
    "12:40 PM",
    "1:10 PM",
    "1:40 PM",
    "2:10 PM",
    "2:40 PM",
    "3:10 PM",
    "3:40 PM",
    "4:10 PM",
    "4:40 PM",
    "5:10 PM",
    "5:40 PM",
    "6:10 PM",
    "6:40 PM",
    "7:10 PM",
    "7:11 AM",
    "7:41 AM",
    "8:11 AM",
    "8:41 AM",
    "9:11 AM",
    "9:41 AM",
    "10:11 AM",
    "10:41 AM",
    "11:11 AM",
    "11:41 AM",
    "12:11 PM",
    "12:41 PM",
    "1:11 PM",
    "1:41 PM",
    "2:11 PM",
    "2:41 PM",
    "3:11 PM",
    "3:41 PM",
    "4:11 PM",
    "4:41 PM",
    "5:11 PM",
    "5:41 PM",
    "6:11 PM",
    "6:41 PM",
    "7:11 PM",
    "7:12 AM",
    "7:42 AM",
    "8:12 AM",
    "8:42 AM",
    "9:12 AM",
    "9:42 AM",
    "10:12 AM",
    "10:42 AM",
    "11:12 AM",
    "11:42 AM",
    "12:12 PM",
    "12:42 PM",
    "1:12 PM",
    "1:42 PM",
    "2:12 PM",
    "2:42 PM",
    "3:12 PM",
    "3:42 PM",
    "4:12 PM",
    "4:42 PM",
    "5:12 PM",
    "5:42 PM",
    "6:12 PM",
    "6:42 PM",
    "7:12 PM",
    "7:14 AM",
    "7:44 AM",
    "8:14 AM",
    "8:44 AM",
    "9:14 AM",
    "9:44 AM",
    "10:14 AM",
    "10:44 AM",
    "11:14 AM",
    "11:44 AM",
    "12:14 PM",
    "12:44 PM",
    "1:14 PM",
    "1:44 PM",
    "2:14 PM",
    "2:44 PM",
    "3:14 PM",
    "3:44 PM",
    "4:14 PM",
    "4:44 PM",
    "5:14 PM",
    "5:44 PM",
    "6:14 PM",
    "6:44 PM",
    "7:14 PM",
    "7:18 AM",
    "7:48 AM",
    "8:18 AM",
    "8:48 AM",
    "9:18 AM",
    "9:48 AM",
    "10:18 AM",
    "10:48 AM",
    "11:18 AM",
    "11:48 AM",
    "12:18 PM",
    "12:48 PM",
    "1:18 PM",
    "1:48 PM",
    "2:18 PM",
    "2:48 PM",
    "3:18 PM",
    "3:48 PM",
    "4:18 PM",
    "4:48 PM",
    "5:18 PM",
    "5:48 PM",
    "6:18 PM",
    "6:48 PM",
    "7:18 PM",
    "7:23 AM",
    "7:53 AM",
    "8:23 AM",
    "8:53 AM",
    "9:23 AM",
    "9:53 AM",
    "10:23 AM",
    "10:53 AM",
    "11:23 AM",
    "11:53 AM",
    "12:23 PM",
    "12:53 PM",
    "1:23 PM",
    "1:53 PM",
    "2:23 PM",
    "2:53 PM",
    "3:23 PM",
    "3:53 PM",
    "4:23 PM",
    "4:53 PM",
    "5:23 PM",
    "5:53 PM",
    "6:23 PM",
    "6:53 PM",
    "7:23 PM",
    "7:25 AM",
    "7:55 AM",
    "8:25 AM",
    "8:55 AM",
    "9:25 AM",
    "9:55 AM",
    "10:25 AM",
    "10:55 AM",
    "11:25 AM",
    "11:55 AM",
    "12:25 PM",
    "12:55 PM",
    "1:25 PM",
    "1:55 PM",
    "2:25 PM",
    "2:55 PM",
    "3:25 PM",
    "3:55 PM",
    "4:25 PM",
    "4:55 PM",
    "5:25 PM",
    "5:55 PM",
    "6:25 PM",
    "6:55 PM",
    "7:25 PM",
    "7:27 AM",
    "7:57 AM",
    "8:27 AM",
    "8:57 AM",
    "9:27 AM",
    "9:57 AM",
    "10:27 AM",
    "10:57 AM",
    "11:27 AM",
    "11:57 AM",
    "12:27 PM",
    "12:57 PM",
    "1:27 PM",
    "1:57 PM",
    "2:27 PM",
    "2:57 PM",
    "3:27 PM",
    "3:57 PM",
    "4:27 PM",
    "4:57 PM",
    "5:27 PM",
    "5:57 PM",
    "6:27 PM",
    "6:57 PM",
    "7:27 PM",
    "7:28 AM",
    "7:58 AM",
    "8:28 AM",
    "8:58 AM",
    "9:28 AM",
    "9:58 AM",
    "10:28 AM",
    "10:58 AM",
    "11:28 AM",
    "11:58 AM",
    "12:28 PM",
    "12:58 PM",
    "1:28 PM",
    "1:58 PM",
    "2:28 PM",
    "2:58 PM",
    "3:28 PM",
    "3:58 PM",
    "4:28 PM",
    "4:58 PM",
    "5:28 PM",
    "5:58 PM",
    "6:28 PM",
    "6:58 PM",
    "7:28 PM",
    "7:20 AM",
    "7:50 AM",
    "8:20 AM",
    "8:50 AM",
    "9:20 AM",
    "9:50 AM",
    "10:20 AM",
    "10:50 AM",
    "11:20 AM",
    "11:50 AM",
    "12:20 PM",
    "12:50 PM",
    "1:20 PM",
    "1:50 PM",
    "2:20 PM",
    "2:50 PM",
    "3:20 PM",
    "3:50 PM",
    "4:20 PM",
    "4:50 PM",
    "5:20 PM",
    "5:50 PM",
    "6:20 PM",
    "6:50 PM",
    "7:20 PM",
    "7:21 AM",
    "7:51 AM",
    "8:21 AM",
    "8:51 AM",
    "9:21 AM",
    "9:51 AM",
    "10:21 AM",
    "10:51 AM",
    "11:21 AM",
    "11:51 AM",
    "12:21 PM",
    "12:51 PM",
    "1:21 PM",
    "1:51 PM",
    "2:21 PM",
    "2:51 PM",
    "3:21 PM",
    "3:51 PM",
    "4:21 PM",
    "4:51 PM",
    "5:21 PM",
    "5:51 PM",
    "6:21 PM",
    "6:51 PM",
    "7:21 PM"
]

let centralTimes = [
"6:45 AM",
"7:05 AM",
"7:25 AM",
"7:45 AM",
"8:05 AM",
"8:25 AM",
"8:45 AM",
"9:05 AM",
"9:25 AM",
"9:45 AM",
"10:05 AM",
"10:25 AM",
"10:45 AM",
"4:15 PM",
"4:35 PM",
"4:55 PM",
"5:15 PM",
"5:35 PM",
"5:55 PM",
"6:15 PM",
"6:35 PM",
"6:55 PM",
"7:15 PM",
"6:49 AM",
"7:09 AM",
"7:29 AM",
"7:49 AM",
"8:09 AM",
"8:29 AM",
"8:49 AM",
"9:09 AM",
"9:29 AM",
"9:49 AM",
"10:09 AM",
"10:29 AM",
"10:49 AM",
"4:19 PM",
"4:39 PM",
"4:59 PM",
"5:19 PM",
"5:39 PM",
"5:59 PM",
"6:19 PM",
"6:39 PM",
"6:59 PM",
"6:52 AM",
"7:12 AM",
"7:32 AM",
"7:52 AM",
"8:12 AM",
"8:32 AM",
"8:52 AM",
"9:12 AM",
"9:32 AM",
"9:52 AM",
"10:12 AM",
"10:32 AM",
"10:52 AM",
"4:22 PM",
"4:42 PM",
"5:02 PM",
"5:22 PM",
"5:42 PM",
"6:02 PM",
"6:22 PM",
"6:42 PM",
"7:02 PM",
"6:58 AM",
"7:18 AM",
"7:38 AM",
"7:58 AM",
"8:18 AM",
"8:38 AM",
"8:58 AM",
"9:18 AM",
"9:38 AM",
"9:58 AM",
"10:18 AM",
"10:38 AM",
"10:58 AM",
"4:28 PM",
"4:48 PM",
"5:08 PM",
"5:28 PM",
"5:48 PM",
"6:08 PM",
"6:28 PM",
"6:48 PM",
"7:08 PM",
"7:02 AM",
"7:22 AM",
"7:42 AM",
"8:02 AM",
"8:22 AM",
"8:42 AM",
"9:02 AM",
"9:22 AM",
"9:42 AM",
"10:02 AM",
"10:22 AM",
"10:42 AM",
"11:02 AM",
"4:32 PM",
"4:52 PM",
"5:12 PM",
"5:32 PM",
"5:52 PM",
"6:12 PM",
"6:32 PM",
"6:52 PM",
"7:12 PM",
"6:47 AM",
"7:07 AM",
"7:27 AM",
"7:47 AM",
"8:07 AM",
"8:27 AM",
"8:47 AM",
"9:07 AM",
"9:27 AM",
"9:47 AM",
"10:07 AM",
"10:27 AM",
"10:47 AM",
"4:17 PM",
"4:37 PM",
"4:57 PM",
"5:17 PM",
"5:37 PM",
"5:57 PM",
"6:17 PM",
"6:37 PM",
"6:57 PM",
"6:51 AM",
"7:11 AM",
"7:31 AM",
"7:51 AM",
"8:11 AM",
"8:31 AM",
"8:51 AM",
"9:11 AM",
"9:31 AM",
"9:51 AM",
"10:11 AM",
"10:31 AM",
"10:51 AM",
"4:21 PM",
"4:41 PM",
"5:01 PM",
"5:21 PM",
"5:41 PM",
"6:01 PM",
"6:21 PM",
"6:41 PM",
"7:01 PM",
"6:55 AM",
"7:15 AM",
"7:35 AM",
"7:55 AM",
"8:15 AM",
"8:35 AM",
"8:55 AM",
"9:15 AM",
"9:35 AM",
"9:55 AM",
"10:15 AM",
"10:35 AM",
"10:55 AM",
"4:25 PM",
"4:45 PM",
"5:05 PM",
"5:25 PM",
"5:45 PM",
"6:05 PM",
"6:25 PM",
"6:45 PM",
"7:05 PM",
"7:00 AM",
"7:20 AM",
"7:40 AM",
"8:00 AM",
"8:20 AM",
"8:40 AM",
"9:00 AM",
"9:20 AM",
"9:40 AM",
"10:00 AM",
"10:20 AM",
"10:40 AM",
"11:00 AM",
"4:30 PM",
"4:50 PM",
"5:10 PM",
"5:30 PM",
"5:50 PM",
"6:10 PM",
"6:30 PM",
"6:50 PM",
"7:10 PM"
]

let rfsTimes = [
    "7:00 AM",
    "7:05 AM",
    "7:10 AM",
    "7:35 AM",
    "7:40 AM",
    "7:42 AM",
    "7:48 AM",
    "7:53 AM",
    "8:02 AM",
    "8:05 AM",
    "8:35 AM",
    "8:40 AM",
    "8:45 AM",
    "9:10 AM",
    "9:15 AM",
    "9:17 AM",
    "9:23 AM",
    "9:28 AM",
    "9:35 AM",
    "9:38 AM",
    "9:40 AM",
    "9:45 AM",
    "9:50 AM",
    "10:10 AM",
    "10:15 AM",
    "10:17 AM",
    "10:23 AM",
    "10:28 AM",
    "10:35 AM",
    "10:38 AM",
    "10:40 AM",
    "10:45 AM",
    "10:50 AM",
    "11:10 AM",
    "11:15 AM",
    "11:17 AM",
    "11:23 AM",
    "11:28 AM",
    "11:35 AM",
    "11:38 AM",
    "11:40 AM",
    "11:45 AM",
    "11:50 AM",
    "12:10 PM",
    "12:15 PM",
    "12:17 PM",
    "12:23 PM",
    "12:28 PM",
    "12:35 PM",
    "12:38 PM",
    "12:40 PM",
    "12:45 PM",
    "12:50 PM",
    "1:10 PM",
    "1:15 PM",
    "1:17 PM",
    "1:23 PM",
    "1:28 PM",
    "1:35 PM",
    "1:38 PM",
    "1:40 PM",
    "1:45 PM",
    "1:50 PM",
    "2:10 PM",
    "2:15 PM",
    "2:17 PM",
    "2:23 PM",
    "2:28 PM",
    "2:35 PM",
    "2:38 PM",
    "2:40 PM",
    "2:45 PM",
    "2:50 PM",
    "3:10 PM",
    "3:15 PM",
    "3:17 PM",
    "3:23 PM",
    "3:28 PM",
    "3:35 PM",
    "3:38 PM",
    "3:40 PM",
    "3:45 PM",
    "3:50 PM",
    "4:10 PM",
    "4:15 PM",
    "4:17 PM",
    "4:23 PM",
    "4:28 PM",
    "4:35 PM",
    "4:38 PM",
    "5:05 PM",
    "5:10 PM",
    "5:15 PM",
    "5:30 PM",
    "5:40 PM",
    "5:42 PM",
    "5:48 PM",
    "5:53 PM",
    "6:00 PM",
    "6:03 PM",
    "6:05 PM",
    "6:10 PM",
    "6:15 PM",
    "6:30 PM",
    "6:40 PM",
    "6:42 PM"
]



let populateBusStops: () -> [BusStop] = {
    let evansStop: BusStop = BusStop(title: "Evans Hall: Hearst Mining", subtitle: "Bus Stop", coordinates: (37.873437, -122.257375), busLines: ["H", "Perimeter", "Central Campus", "RFS"])
    let strawberryStop: BusStop = BusStop(title: "Strawberry Canyon", subtitle: "Bus Stop", coordinates: (37.872387, -122.247741), busLines: ["H"])
    let botanicalStop: BusStop = BusStop(title: "Botanical Gardens", subtitle: "Bus Stop", coordinates: (37.875754, -122.238648), busLines: ["H"])
    let lawrenceHall: BusStop = BusStop(title: "Lawrence Hall of Science", subtitle: "Bus Stop", coordinates: (37.879872, -122.246195), busLines: ["H"])
    let spaceStop: BusStop = BusStop(title: "Space Sciences Lab", subtitle: "Bus Stop", coordinates: (37.880792, -122.244151), busLines: ["H"])

    for i in 0..<hillLineTimes.count {
        switch i % 9 {
        case 0:
            evansStop.schedule["H"]!.append(("Towards Lawrence Hall", hillLineTimes[i]))
        case 1:
            strawberryStop.schedule["H"]!.append(("Towards Lawrence Hall", hillLineTimes[i]))
        case 2:
            botanicalStop.schedule["H"]!.append(("Towards Lawrence Hall", hillLineTimes[i]))
        case 3:
            lawrenceHall.schedule["H"]!.append(("Towards Lawrence Hall", hillLineTimes[i]))
        case 4:
            spaceStop.schedule["H"]!.append(("Towards Evans Hall", hillLineTimes[i]))
        case 5:
            lawrenceHall.schedule["H"]!.append(("Towards Evans Hall", hillLineTimes[i]))
        case 6:
            botanicalStop.schedule["H"]!.append(("Towards Evans Hall", hillLineTimes[i]))
        case 7:
            strawberryStop.schedule["H"]!.append(("Towards Evans Hall", hillLineTimes[i]))
        default:
            ()
        }
    }
    
    let bartStop = BusStop(title: "Downtown Berkeley BART", subtitle: "Bus Stop", coordinates: (37.871088, -122.267621), busLines: ["Perimeter", "Central Campus", "RFS"])
    let oxfordStop = BusStop(title: "Oxford and University", subtitle: "Bus Stop", coordinates: (37.872763, -122.265942), busLines: ["Perimeter", "Central Campus", "RFS"])
    let hearstStop = BusStop(title: "Hearst Ave: Tollman Hall", subtitle: "Bus Stop", coordinates: (37.874436, -122.264212), busLines: ["Perimeter", "Central Campus"])
    let northStop = BusStop(title: "Hearst Ave: North Gate Hall", subtitle: "Bus Stop", coordinates: (37.874944, -122.260542), busLines: ["Perimeter", "Central Campus"])
    let coryStop = BusStop(title: "Hearst Ave: Cory Hall", subtitle: "Bus Stop", coordinates: (37.875320, -122.257968), busLines: ["Perimeter", "Central Campus"])
    let greekStop = BusStop(title: "Gayley Ave: Greek Theatre", subtitle: "Bus Stop", coordinates: (37.872633, -122.253985), busLines: ["Perimeter"])
    let facultyStop = BusStop(title: "Piedmont Ave: Haas", subtitle: "Bus Stop", coordinates: (37.871016, -122.252827), busLines: ["Perimeter"])
    let ihouseStop = BusStop(title: "Bancroft Ave: I House", subtitle: "Bus Stop", coordinates: (37.869618, -122.252646), busLines: ["Perimeter"])
    let channingStop = BusStop(title: "Piedmont and Channing", subtitle: "Bus Stop", coordinates: (37.867492, -122.251989), busLines: ["Perimeter"])
    let collegeStop = BusStop(title: "College and Haste", subtitle: "Bus Stop", coordinates: (37.866819, -122.254060), busLines: ["Perimeter"])
    let bancroftStop = BusStop(title: "Bancroft and College", subtitle: "Bus Stop", coordinates: (37.869295, -122.255131), busLines: ["Perimeter"])
    let hearstGymStop = BusStop(title: "Hearst Gym", subtitle: "Bus Stop", coordinates: (37.869063, -122.256949), busLines: ["Perimeter"])
    let upperSproulStop = BusStop(title: "Upper Sproul", subtitle: "Bus Stop", coordinates: (37.868816, -122.258989), busLines: ["Perimeter"])
    let rsfStop = BusStop(title: "RSF", subtitle: "Bus Stop", coordinates: (37.868168, -122.264113), busLines: ["Perimeter"])
    let shattuckStop = BusStop(title: "Bancroft and Shattuck", subtitle: "Bus Stop", coordinates: (37.867689, -122.267501), busLines: ["Perimeter"])
    let otherShattuckStop = BusStop(title: "Shattuck and Kittredge", subtitle: "Bus Stop", coordinates: (37.868413, -122.267706), busLines: ["Perimeter"])
    
    for i in 0..<perimeterLineTimes.count {
        if i <= 26 {
            bartStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 51 {
            oxfordStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 76 {
            hearstStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 101 {
            northStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 126 {
            coryStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 151 {
            evansStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 176 {
            greekStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 201 {
            facultyStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 226 {
            ihouseStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 251 {
            channingStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 276 {
            collegeStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 301 {
            upperSproulStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 326 {
            rsfStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 351 {
            shattuckStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 376 {
            otherShattuckStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 401 {
            bancroftStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        } else if i <= 426 {
            hearstGymStop.schedule["Perimeter"]!.append(("", perimeterLineTimes[i]))
        }
    }

        let moffittStop = BusStop(title: "Moffitt Library", subtitle: "Bus Stop", coordinates: (37.873421, -122.259836), busLines: ["Central Campus"])
        let westCircleStop = BusStop(title: "Bancroft and Shattuck", subtitle: "Bus Stop", coordinates: (37.872008, -122.263417), busLines: ["Central Campus"])
        let liKaShingStop = BusStop(title: "Shattuck and Kittredge", subtitle: "Bus Stop", coordinates: (37.871650, -122.265083), busLines: ["Central Campus"])

        for i in 0..<centralTimes.count {
        if i <= 23 {
            bartStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 45 {
            oxfordStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 67 {
            hearstStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 89 {
            northStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 111 {
            coryStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 133 {
            evansStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 155 {
            moffittStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 177 {
            westCircleStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        } else if i <= 199 {
            liKaShingStop.schedule["Central Campus"]!.append(("", centralTimes[i]))
        }
        }
    
    let regattaStop = BusStop(title: "Regatta Facility", subtitle: "Bus Stop", coordinates: (37.916308, -122.338663), busLines: ["RFS"])
    let buchanonStop = BusStop(title: "Buchanon and Jackson", subtitle: "Bus Stop", coordinates: (37.887562, -122.301023), busLines: ["RFS"])
    let hopkinsStop = BusStop(title: "Hopkins and MLK Jr.", subtitle: "Bus Stop", coordinates: (37.885506, -122.275125), busLines: ["RFS"])
    
    for i in 0..<rfsTimes.count {
        switch i % 10 {
        case 0:
            regattaStop.schedule["RFS"]!.append(("Towards Downtown Berkeley", rfsTimes[i]))
        case 1:
            buchanonStop.schedule["RFS"]!.append(("Towards Downtown Berkeley", rfsTimes[i]))
        case 2:
            hopkinsStop.schedule["RFS"]!.append(("Towards Downtown Berkeley", rfsTimes[i]))
        case 3:
            evansStop.schedule["RFS"]!.append(("Towards Downtown Berkeley", rfsTimes[i]))
        case 4:
            oxfordStop.schedule["RFS"]!.append(("Towards Downtown Berkeley", rfsTimes[i]))
        case 5:
            bartStop.schedule["RFS"]!.append(("Towards Richmond", rfsTimes[i]))
        case 6:
            hopkinsStop.schedule["RFS"]!.append(("Towards Richmond", rfsTimes[i]))
        case 7:
            buchanonStop.schedule["RFS"]!.append(("Towards Richmond", rfsTimes[i]))
        default:
            ()
        }
    }
    
    return [evansStop, strawberryStop, botanicalStop, lawrenceHall, spaceStop, bartStop, oxfordStop, hearstStop, northStop, coryStop, greekStop, facultyStop, ihouseStop, channingStop, collegeStop, bancroftStop, hearstGymStop, upperSproulStop, rsfStop, shattuckStop, otherShattuckStop, moffittStop, westCircleStop, liKaShingStop, regattaStop, buchanonStop, hopkinsStop]
}




