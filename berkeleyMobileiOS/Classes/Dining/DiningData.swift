//
//  DiningData.swift
//  BerkeleyMobile iOS
//
//  Bohui Moon (@bohuim) | 2016.10.14
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation 

enum MealType: String {
    case Breakfast
    case Lunch
    case Dinner
    case LateNight
}

/**
 * Data wrapper for a dining hall.
 */
class DiningHall
{
    let name: String
    let imageURL: URL
    
    var breakfastMenu: [DiningMenu]  = []
    var breakfastOpen: Date?         = nil
    var breakfastClose: Date?        = nil
    
    var lunchMenu: [DiningMenu]      = []
    var lunchOpen: Date?             = nil
    var lunchClose: Date?            = nil
    
    var dinnerMenu: [DiningMenu]     = []
    var dinnerOpen: Date?            = nil
    var dinnerClose: Date?           = nil
    
    var lateNightMenu: [DiningMenu]  = []
    var lateNightOpen: Date?         = nil
    var lateNightClose: Date?        = nil
    
    init(name: String, imageLink: String)
    {
        self.name = name
        self.imageURL = URL(string: imageLink)!
    }
    
    var isOpen: Bool
    {
        get {
            let now = Date()
            
            return 
               (!self.breakfastMenu.isEmpty && now.isBetween(self.breakfastOpen, breakfastClose))
            || (!self.lunchMenu.isEmpty     && now.isBetween(self.lunchOpen, lunchClose)        )
            || (!self.dinnerMenu.isEmpty    && now.isBetween(self.dinnerOpen, dinnerClose)      )
            || (!self.lateNightMenu.isEmpty && now.isBetween(self.lateNightOpen, lateNightClose))
        }
    }
    
    var description: String
    {
        return "DiningHall \(self.name)"
    }
}

/**
 * Data wrapper for a menu at a dining hall.
 */
class DiningMenu
{
    var name: String
    var mealType: MealType
    weak var hall: DiningHall?
    
    init(name: String, type: MealType, hall: DiningHall?)
    {
        self.name = name
        self.mealType = type
        self.hall = hall
    }
}
