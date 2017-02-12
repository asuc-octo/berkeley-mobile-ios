/**
 * DiningData.swift
 *
 * This file defines all the data types related to dining.
 * Note: DiningHall and Item are declared as classes, not structs to avoid copying potentially large data.  
 */

import Foundation 

/**
 * `MealType` is one of four: 
 * - Breakfast
 * - Lunch
 * - Dinner
 * - Late night
 */
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

/** 
 * `MealShift` contains the menu and hours of a specific MealType.
 */
class MealShift
{
    var menu: DiningMenu = []
    var open: Date? = nil
    var close: Date? = nil
}


/**
 * `DiningHall` represents a single physical dining location.
 * Each hall contains the `DiningMenu`, Open & Close times for every `MealType`.
 */
class DiningHall: Resource
{
    // Map of MealType to MealShift, which inclues the menu and opening & closing times.  
    typealias MealMap = [MealType : MealShift]
    
    let meals: MealMap = MealType.allValues.reduce(MealMap())
    { (dict, type) -> MealMap in
        
        var dict = dict
        dict[type] = MealShift()
        return dict
    }
    
    /// Returns whether the hall is currently open.
    override var isOpen: Bool
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


/** 
 * `DiningItem` represents a single dish/item.
 * Contains a refernce to the `DiningHall` and `MealType` of where and when this item is served.
 */ 
class DiningItem: Favorable
{
    var name: String
    var mealType: MealType
    weak var hall: DiningHall?
    
    var isFavorited: Bool
    
    init(name: String, type: MealType, hall: DiningHall?, favorited: Bool = false)
    {
        self.name = name
        self.mealType = type
        self.hall = hall
        
        self.isFavorited = favorited
    }
}
