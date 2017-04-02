//
//  CampusResource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/25/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class CampusResource: Resource {
    let campusLocation: String?
    let phoneNumber: String?
    let alternatePhoneNumber: String?
    let email: String?
    let hours: String?
    let latitude: Double?
    let longitude: Double?
    let notes: String?
    var favorited: Bool? = false
    
    init(name: String, campusLocation: String?, phoneNumber: String?, alternatePhoneNumber: String?, email: String?, hours: String?, latitude: Double?, longitude: Double?, notes: String?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.alternatePhoneNumber = alternatePhoneNumber
        self.email = email
        self.hours = hours
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        super.init(name: name,  type:ResourceType.Library, imageLink: nil)
    }
}
