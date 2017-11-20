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
    static var detailProvider: ResourceDetailProvider.Type? = CampusResourceDetailViewController.self
    
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let campusLocation: String?
    let phoneNumber: String?
    let alternatePhoneNumber: String?
    let email: String?
    let hours: String?
    let latitude: Double?
    let longitude: Double?
    let notes: String?
    
    var isOpen: Bool {
        return false
    }
    
    init(name: String, campusLocation: String?, phoneNumber: String?, alternatePhoneNumber: String?, email: String?, hours: String?, latitude: Double?, longitude: Double?, notes: String?, imageLink: String?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.alternatePhoneNumber = alternatePhoneNumber
        self.email = email
        self.hours = hours
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }
}
