//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class Library: Resource {
    var image: UIImage?
    
    
    static func displayName(pluralized: Bool) -> String {
        return "Librar" + (pluralized ? "ies" : "y")
    }
    
    static var dataSource: ResourceDataSource.Type? = LibraryDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = nil
    
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let campusLocation: String?
    let phoneNumber: String?
    var weeklyOpeningTimes:[Date?]
    var weeklyClosingTimes:[Date?]
    var weeklyByAppointment:[Bool]
    let latitude: Double?
    let longitude: Double?
    
    init(name: String, campusLocation: String?, phoneNumber: String?, weeklyOpeningTimes:[Date?], weeklyClosingTimes:[Date?], weeklyByAppointment:[Bool], imageLink: String?, latitude: Double?, longitude: Double?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.weeklyOpeningTimes = weeklyOpeningTimes
        self.weeklyClosingTimes = weeklyClosingTimes
        self.weeklyByAppointment = weeklyByAppointment
        self.latitude = latitude
        self.longitude = longitude
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }
    
    var isOpen: Bool {
        if self.weeklyOpeningTimes.count == 0 {
            return false
        }
        var status = false
        let dow = Calendar.current.component(.weekday, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        var ind = 0
        if let opening = (self.weeklyOpeningTimes[ind]) {
            if let closing = (self.weeklyClosingTimes[ind]) {
                if (Date() >= opening && Date() <= closing) {
                    status = true
                }
            }
        }
        return status
    }

}

