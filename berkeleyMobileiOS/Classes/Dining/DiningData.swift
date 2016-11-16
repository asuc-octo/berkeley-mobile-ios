/**
 * DiningData.swift
 *
 * This file defines all the data types related to dining.
 * Note: DiningHall and Item are declared as classes, not structs to avoid copying potentially large data.  
 */

import Foundation 

/**
 * Types of meals include: breakfast, lunch, dinner, and late night. 
 */
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
 * DiningHall represents a single physical dining location.
 * Each hall contains the DiningMenu, Open & Close times for every MealType.
 */
class DiningHall
{
    let name: String
    let imageURL: String
    
    var breakfastMenu: DiningMenu = []
    var breakfastOpen: Date?      = nil
    var breakfastClose: Date?     = nil
    
    var lunchMenu: DiningMenu     = []
    var lunchOpen: Date?          = nil
    var lunchClose: Date?         = nil
    
    var dinnerMenu: DiningMenu    = []
    var dinnerOpen: Date?         = nil
    var dinnerClose: Date?        = nil
    
    var lateNightMenu: DiningMenu = []
    var lateNightOpen: Date?      = nil
    var lateNightClose: Date?     = nil
    
    init(name: String, url: String)
    {
        self.name = name
        self.imageURL = url
    }
    
    /// String description is simply "DiningHall <name>"
    var description: String
    {
        return "DiningHall \(self.name)"
    }
    
    /// Returns whether the hall is currently open.
    public var isOpen: Bool
    {
        let now = Date()
        
        return 
           (!self.breakfastMenu.isEmpty && now.isBetween(self.breakfastOpen, breakfastClose))
        || (!self.lunchMenu.isEmpty     && now.isBetween(self.lunchOpen, lunchClose)        )
        || (!self.dinnerMenu.isEmpty    && now.isBetween(self.dinnerOpen, dinnerClose)      )
        || (!self.lateNightMenu.isEmpty && now.isBetween(self.lateNightOpen, lateNightClose))
    }
    
    /// Returns the DiningMenu for the given MealType.
    public func menuForType(_ type: MealType) -> DiningMenu
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
 * DiningMenu is a list of DiningItems.
 * - note: DiningMenu is not an actual type, but a typealias for [DiningItem]
 */
typealias DiningMenu = [DiningItem]

/**
 * DiningHall represents a single dish/item. 
 */
class DiningItem
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
