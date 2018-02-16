/**
 * DiningData.swift
 *
 * This file defines all the data types related to dining.
 * Note: DiningHall and Item are declared as classes, not structs to avoid copying potentially large data.  
 */

import Foundation 
import UIKit
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
        dinner    = "dinner"
    
    static let allValues = [breakfast, lunch, dinner]
    
    var name: String {
        return self.rawValue.capitalized
    }
}

/// Represents a single meal slot with a `DiningMenu` and open hours as `DateRange`.
struct MealShift
{
    var menu: DiningMenu
    let hours: DateRange?
    
    init(menu: DiningMenu, hours: DateRange?)
    {
        self.menu = menu
        self.hours = hours
    }
    
    var isOpen: Bool
    {
        return !menu.isEmpty && (hours?.isActive ?? false)
    }
}

typealias MealMap = [MealType : MealShift]


/**
 * `DiningHall` represents a single physical dining location.
 * Each hall contains the `DiningMenu`, Open & Close times for every `MealType`.
 */
class DiningHall: Resource
{
    var image: UIImage?
    
    static func displayName(pluralized: Bool) -> String
    {
        return "Dining Hall" + (pluralized ? "s" : "")
    }
    
    static var dataSource: ResourceDataSource.Type? = DiningDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = DiningHallViewController.self
    
    
    let name: String
    let imageURL: URL?
    let meals: MealMap
    
    var isFavorited: Bool = false
    
    init(name: String, imageLink: String?, shifts: MealMap)
    {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        
        self.meals = shifts
    }
    
    /// Returns whether the hall is currently open.
    var isOpen: Bool
    {
        return meals.reduce(false){ $0 || $1.value.isOpen }
    }
    
    /// Returns the DiningMenu for the given MealType.
    func menuForType(_ type: MealType) -> DiningMenu
    {
        return meals[type]!.menu
    }
}



class CafeClass: Resource
{
    var image: UIImage?
    
    static func displayName(pluralized: Bool) -> String
    {
        return "Cafe" + (pluralized ? "s" : "")
    }
    
    static var dataSource: ResourceDataSource.Type? = CafeDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = DiningHallViewController.self
    
    
    let name: String
    let imageURL: URL?
    let meals: MealMap
    
    var isFavorited: Bool = false
    
    init(name: String, imageLink: String?, shifts: MealMap)
    {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        
        self.meals = shifts
    }
    
    /// Returns whether the hall is currently open.
    var isOpen: Bool
    {
        return meals.reduce(false){ $0 || $1.value.isOpen }
    }
    
    /// Returns the DiningMenu for the given MealType.
    func menuForType(_ type: MealType) -> DiningMenu
    {
        return meals[type]!.menu
    }
}


/// DiningMenu is a typealias for an array of DiningItems.
typealias DiningMenu = Array<DiningItem>


/** 
 * `DiningItem` represents a single dish/item.
 * Contains a refernce to the `DiningHall` and `MealType` of where and when this item is served.
 */ 
class DiningItem: Favorable
{
    let name: String
    let mealType: MealType
    var isFavorited: Bool
    
    init(name: String, type: MealType, favorited: Bool = false)
    {
        self.name = name
        self.mealType = type
        
        self.isFavorited = favorited
    }
}
