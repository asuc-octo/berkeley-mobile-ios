/**
 * DiningData.swift
 *
 * This file defines all the data types related to dining.
 * Note: DiningHall and Item are declared as classes, not structs to avoid copying potentially large data.  
 */

import Foundation 

/// Types of meals include: breakfast, lunch, dinner, and late night.
enum MealType: String
{
    case 
        breakfast = "breakfast", 
        lunch     = "lunch", 
        dinner    = "dinner", 
        lateNight = "late_night"
    
    static let allValues = [breakfast, lunch, dinner, lateNight]
    
    var name: String {
        return (self == .lateNight) ? "Late Night" : self.rawValue.capitalized
    }
}

/// MealShift contains the menu and hours of a specific MealType.
class MealShift
{
    var menu: DiningMenu = []
    var open: Date? = nil
    var close: Date? = nil
}


/**
 * DiningHall represents a single physical dining location.
 * Each hall contains the DiningMenu, Open & Close times for every MealType.
 */
class DiningHall
{
    let name: String
    let imageURL: String?
    
    
    // Map of MealType to MealShift, which inclues the menu and opening & closing times.  
    typealias MealMap = [MealType : MealShift]
    
    let meals: MealMap = MealType.allValues.reduce(MealMap())
    { (dict, type) -> MealMap in
        
        var dict = dict
        dict[type] = MealShift()
        return dict
    }

    
    /// Initialize DiningHall with a name and optional image URL string. 
    init(name: String, url: String?)
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
        
        for (_, shift) in meals
        {
            if !shift.menu.isEmpty && now.isBetween(shift.open, shift.close) {
                return true
            }
        }
        return false
    }
    
    /// Returns the DiningMenu for the given MealType.
    public func menuForType(_ type: MealType) -> DiningMenu
    {
        return meals[type]!.menu
    }
}


/// DiningMenu is a typealias for an array of DiningItems.
typealias DiningMenu = [DiningItem]


/// DiningHall represents a single dish/item. 
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
