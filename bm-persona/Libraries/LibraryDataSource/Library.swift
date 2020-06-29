//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit

class Library: SearchItem, HasLocation, HasOpenTimes, HasOccupancy {
    
    static var nearbyDistance: Double = 10
    static var invalidDistance: Double = 100
    
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
    var icon: UIImage?
    
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
    let weeklyHours: WeeklyHours?
    var occupancy: Occupancy?
    var weeklyByAppointment:[Bool]
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, campusLocation: String?, phoneNumber: String?, weeklyHours: WeeklyHours?, weeklyByAppointment:[Bool], imageLink: String?, latitude: Double?, longitude: Double?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.weeklyByAppointment = weeklyByAppointment
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(named: "Book")
    }

}

