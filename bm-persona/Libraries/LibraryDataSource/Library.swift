//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class Library: SearchItem {
    
    var text: Set<String> {
        return [name]
    }
    
    var image: UIImage?
    
    static func displayName(pluralized: Bool) -> String {
        return "Librar" + (pluralized ? "ies" : "y")
    }
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let campusLocation: String?
    let phoneNumber: String?
    let weeklyHours: [DateInterval?]
    var weeklyByAppointment:[Bool]
    let latitude: Double?
    let longitude: Double?
    
    init(name: String, campusLocation: String?, phoneNumber: String?, weeklyHours: [DateInterval?], weeklyByAppointment:[Bool], imageLink: String?, latitude: Double?, longitude: Double?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.weeklyByAppointment = weeklyByAppointment
        self.latitude = latitude
        self.longitude = longitude
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }
    
    var isOpen: Bool {
        if self.weeklyHours.count == 0 {
            return false
        }
        var status = false
        if let interval = self.weeklyHours[Date().weekday()] {
            if interval.contains(Date()) || interval.duration == 0 {
                status = true
            }
        }
        return status
    }

}

