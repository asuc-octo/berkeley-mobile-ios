//
//  Cafe.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class Cafe: HasOpenTimes, SearchItem, HasLocation {
    static var nearbyDistance: Double = 10
    static var invalidDistance: Double = 100
    
    var isFavorited: Bool = false
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
    
    let name: String
    let imageURL: URL?
    let campusLocation: String?
    let phoneNumber: String?
    
    var meals: MealMap
    var weeklyHours: WeeklyHours?
    var image: UIImage?
    
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, campusLocation: String?, phoneNumber: String?, imageLink: String?, shifts: MealMap, hours: WeeklyHours?, latitude: Double?, longitude: Double?) {
        self.name = name
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.imageURL = URL(string: imageLink ?? "")
        self.meals = shifts
        self.weeklyHours = hours
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
