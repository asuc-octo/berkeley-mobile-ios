//
//  DiningHall.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

/**
    `DiningHall` represents a single physical dining location.
    Each hall contains the `DiningMenu`, Open & Close times for every `MealType`.
*/
#warning("TODO: Make DiningHall implement SearchItem and HasLocation")
class DiningHall: HasOpenTimes {
    
    let name: String
    let imageURL: URL?
    var meals: MealMap
    var weeklyHours: WeeklyHours?
    
    init(name: String, imageLink: String?, shifts: MealMap, hours: WeeklyHours?) {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.meals = shifts
        self.weeklyHours = hours
    }
    
}
