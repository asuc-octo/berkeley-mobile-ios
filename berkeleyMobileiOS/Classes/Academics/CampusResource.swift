//
//  CampusResource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/25/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class CampusResource: Resource {
    var image: UIImage?
    
    
    static func displayName(pluralized: Bool) -> String {
        return "Campus Resource" + (pluralized ? "s" : "")
    }
    
    static var dataSource: ResourceDataSource.Type? = CampusResourceDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = nil
    
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let campusLocation: String?
    let phoneNumber: String?
    let alternatePhoneNumber: String?
    let email: String?
    let weeklyHours: [DateInterval?]
    let byAppointment: Bool
    let latitude: Double?
    let longitude: Double?
    let notes: String?
    let description: String?
    let category: String?
    
    var isOpen: Bool {
        if self.byAppointment || self.weeklyHours.count == 0 {
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
    
    init(name: String, campusLocation: String?, phoneNumber: String?, alternatePhoneNumber: String?, email: String?, weeklyHours: [DateInterval?], byAppointment: Bool, latitude: Double?, longitude: Double?, notes: String?, imageLink: String?, description: String?, category: String?) {
        self.campusLocation = campusLocation?.lowercased() != "nan" ? campusLocation : nil
        self.phoneNumber = TappableInfoType.formattedAs(.phone, str: phoneNumber) ? phoneNumber : nil
        self.alternatePhoneNumber = TappableInfoType.formattedAs(.phone, str: alternatePhoneNumber) ? alternatePhoneNumber : nil
        self.email = TappableInfoType.formattedAs(.email, str: email) ? email : nil
        self.weeklyHours = weeklyHours
        self.byAppointment = byAppointment
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.description = description
        self.category = category
    }
}
