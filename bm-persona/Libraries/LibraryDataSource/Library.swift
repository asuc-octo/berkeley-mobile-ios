//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit

class Library: SearchItem, HasLocation {
    
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (latitude, longitude)
    }
    
    var locationName: String {
        return campusLocation ?? "Berkeley, CA"
    }
    
    var image: UIImage?
    
    static func displayName(pluralized: Bool) -> String {
        return "Librar" + (pluralized ? "ies" : "y")
    }
    
    var description: String {
        return ""
    }
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let campusLocation: String?
    let phoneNumber: String?
    let weeklyHours: [DateInterval?]
    var weeklyByAppointment:[Bool]
    var latitude: Double
    var longitude: Double
    
    init(name: String, campusLocation: String?, phoneNumber: String?, weeklyHours: [DateInterval?], weeklyByAppointment:[Bool], imageLink: String?, latitude: Double?, longitude: Double?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.weeklyByAppointment = weeklyByAppointment
        self.latitude = latitude ?? Double.nan
        self.longitude = longitude ?? Double.nan
        
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

