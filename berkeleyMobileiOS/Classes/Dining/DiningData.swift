//
//  DiningData.swift
//  BerkeleyMobile iOS
//
//  Bohui Moon (@bohuim) | 2016.10.14
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation 

enum MealType: String
{
    case 
        breakfast = "breakfast", 
        lunch     = "lunch", 
        dinner    = "dinner", 
        lateNight = "late_night"
    
    static let allValues = [breakfast, lunch, dinner, lateNight]
    
    var name: String
    {
        get {
            return (self == .lateNight) ? "Late Night" : self.rawValue.capitalized
        }
    }
}

/**
 * Data wrapper for a dining hall.
 */
class DiningHall
{
    let name: String
    let imageURL: String
    
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
    
    init(name: String, url: String)
    {
        self.name = name
        self.imageURL = url
    }
    
    var description: String
    {
        return "DiningHall \(self.name)"
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
    
    public func menuForType(_ type: MealType) -> [DiningMenu]
    {
        switch type
        {
            case .breakfast: return self.breakfastMenu
            case .lunch:     return self.lunchMenu
            case .dinner:    return self.dinnerMenu
            case .lateNight: return self.lateNightMenu
        }
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
