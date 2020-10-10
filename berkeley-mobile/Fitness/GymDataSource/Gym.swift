//
//  Gym.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class Gym: SearchItem, HasLocation, CanFavorite, HasPhoneNumber, HasImage, HasOpenTimes, HasOccupancy {
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
    
    var image: UIImage?
    
    static func displayName(pluralized: Bool) -> String {
        return "Gym" + (pluralized ? "s" : "")
    }
    
    let name: String
    let imageURL: URL?
    let description: String?
    
    var isFavorited: Bool = false
    
    let address: String?
    let phoneNumber: String?
    
    let weeklyHours: WeeklyHours?
    var occupancy: Occupancy?
    
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, description: String?, address: String?, phoneNumber: String?, imageLink: String?, weeklyHours: WeeklyHours?) {
        self.address = address
        self.description = description
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(named: "Walk")
    }

}

