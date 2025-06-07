//
//  BMDiningLocation.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class BMDiningLocation: SearchItem, HasLocation, CanFavorite, HasPhoneNumber, HasImage, HasOpenTimes {
    var icon: UIImage?
    
    var isFavorited: Bool = false
    var searchName: String {
        return name
    }
    
    @Display var name: String
    let imageURL: URL?
    @Display var address: String?
    @Display var phoneNumber: String?
    
    var meals: MealMap
    var weeklyHours: WeeklyHours?
    
    var latitude: Double?
    var longitude: Double?
    
    init(name: String, address: String?, phoneNumber: String?, imageLink: String?, shifts: MealMap, hours: WeeklyHours?, latitude: Double?, longitude: Double?) {
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.imageURL = URL(string: imageLink ?? "")
        self.meals = shifts
        self.weeklyHours = hours
        self.latitude = latitude
        self.longitude = longitude
        self.icon = UIImage(systemName: "fork.knife")
    }
}
