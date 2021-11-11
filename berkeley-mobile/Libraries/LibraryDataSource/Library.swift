//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit

class Library: SearchItem, HasLocation, CanFavorite, HasPhoneNumber, HasImage, HasOpenTimes, HasOccupancy {
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }
    
    var locationName: String {
        return address ?? Strings.defaultLocationBerkeley
    }
    
    var icon: UIImage?
    
    @Display var name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false

    @Display var description: String?
    @Display var address: String?
    @Display var phoneNumber: String?
    let weeklyHours: WeeklyHours?
    var occupancy: Occupancy?
    var weeklyByAppointment:[Bool]
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, description: String?, address: String?, phoneNumber: String?, weeklyHours: WeeklyHours?, weeklyByAppointment:[Bool], imageLink: String?, latitude: Double?, longitude: Double?) {
        self.description = description
        self.address = address
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

