//
//  Gym.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class Gym: SearchItem, HasLocation, HasOpenTimes {
    
    static var nearbyDistance: Double = 10
    static var invalidDistance: Double = 100
    var icon: UIImage?
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }
    
    var locationName: String {
        return "Berkeley, CA"
    }
    
    var description: String {
        return ""
    }
    
    var image: UIImage?
    
    static func displayName(pluralized: Bool) -> String {
        return "Gym" + (pluralized ? "s" : "")
    }
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let address: String?
    let phoneNumber: String?
    
    var openingTimeToday: Date? = nil
    var closingTimeToday: Date? = nil
    var latitude: Double?
    var longitude: Double?
    
    var isOpen: Bool {
        var status = false
        if let open = openingTimeToday,
           let close = closingTimeToday {
            if Date().isBetween(open, close) || close == open {
                status = true
            }
        }
        return status
    }
    
    init(name: String, address: String?, phoneNumber: String?, imageLink: String?, openingTimeToday: Date?, closingTimeToday: Date?) {
        self.address = address
        self.phoneNumber = phoneNumber
        self.openingTimeToday = openingTimeToday
        self.closingTimeToday = closingTimeToday
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(named: "Walk")
    }

}

