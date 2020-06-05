//
//  DiningHall.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//
import Foundation
import UIKit

/**
    `DiningHall` represents a single physical dining hall.
*/
class DiningHall: DiningLocation {
    override init(name: String, campusLocation: String?, phoneNumber: String?, imageLink: String?, shifts: MealMap, hours: WeeklyHours?, latitude: Double?, longitude: Double?) {
        super.init(name: name, campusLocation: campusLocation, phoneNumber: phoneNumber, imageLink: imageLink, shifts: shifts, hours: hours, latitude: latitude, longitude: longitude)
        self.icon = UIImage(named: "Dining")
    }
}
