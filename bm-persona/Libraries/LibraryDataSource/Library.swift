//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit

class Library: SearchItem {
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }
    
    var locationName: String {
        return campusLocation ?? "Berkeley, CA"
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
    
    var distanceToUser: Double = Double.nan
    
    func findDistanceToUser(userLoc: CLLocation) -> Double {
        if  let libLat = self.latitude,
            let libLong = self.longitude,
            !libLat.isNaN && !libLong.isNaN {
            let libLoc = CLLocation(latitude: libLat, longitude: libLong)
            let distance = round(userLoc.distance(from: libLoc) / 1600.0 * 10) / 10
            distanceToUser = distance
            return distanceToUser
        }
        return Double.nan
    }
    
    func getDistanceToUser(userLoc: CLLocation) -> Double {
        if distanceToUser.isNaN {
            return findDistanceToUser(userLoc: userLoc)
        }
        return distanceToUser
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

