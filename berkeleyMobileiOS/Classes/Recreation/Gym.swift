//
//  Gym.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit

class Gym: Resource {
    var image: UIImage?
    
    
    static func displayName(pluralized: Bool) -> String {
        return "Gym" + (pluralized ? "s" : "")
    }
    
    static var dataSource: ResourceDataSource.Type? = GymDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = nil

    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let address: String
    
    var openingTimeToday: Date? = nil
    var closingTimeToday: Date? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    var isOpen: Bool {
        var status = true
        if let t = (openingTimeToday) {
            if t > Date() {
                status = false
            }
        }
        if let t = (closingTimeToday) {
            if t < Date() {
                status = false
            }
        }
        return status
    }
    
    init(name: String, address: String, imageLink: String?, openingTimeToday: Date?, closingTimeToday: Date?) {
        self.address = address
        self.openingTimeToday = openingTimeToday
        self.closingTimeToday = closingTimeToday
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }

}
