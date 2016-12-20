//
//  DiningHallDataSource.swift
//  BerkeleyMobile iOS
//
//  Bohui Moon (@bohuim) | 2016.10.14
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Foundation

import Alamofire
import SwiftyJSON

fileprivate let kDiningHallsEndpoint = "https://asuc-mobile-development.herokuapp.com/api/dining_halls"

/**
 * Static class that fetches the DiningHall related data.
 */
class DiningDataSource: NSObject
{
    typealias completionHandler = (_ halls: [DiningHall]?) -> Void
    
    // Fetch the list of dining halls and report back to the completionHandler.
    static func fetchDiningHalls(_ completion: @escaping completionHandler)
    {
//        Alamofire.request(kDiningHallsEndpoint).responseJSON
//        { response in
//            
//            if response.result.isFailure {
//                print("[Error @ DiningHallDataSource.getDiningHalls()]: request failed")
//                return
//            }
//            
//            let halls = JSON(data: response.data!)["dining_halls"].map { (_, child) in parseDiningHall(child) }
//            completion(halls)
//        }

        do
        {
            let url = Bundle.main.url(forResource: "dining_halls_sample", withExtension: "json")!
            let halls = JSON(data: try Data(contentsOf: url))["dining_halls"].map { (_, child) in parseDiningHall(child) }
            completion(halls)
        }
        catch
        {
            //error
        }
    }
    
    // Return a DiningHall object parsed from JSON.
    private static func parseDiningHall(_ json: JSON) -> DiningHall
    {
        let hall = DiningHall(name: json["name"].stringValue, url: json["image_link"].stringValue)
        
        parseMeal(json, hall, "breakfast",  &hall.breakfastMenu, &hall.breakfastOpen, &hall.breakfastClose)
        parseMeal(json, hall, "lunch",      &hall.lunchMenu,     &hall.lunchOpen,     &hall.lunchClose)
        parseMeal(json, hall, "dinner",     &hall.dinnerMenu,    &hall.dinnerOpen,    &hall.dinnerClose)
        parseMeal(json, hall, "late_night", &hall.lateNightMenu, &hall.lateNightOpen, &hall.lateNightClose)
    
        return hall
    }
    
    // Parse data related to a type of meal for a DiningHall.
    private static func parseMeal(_ json: JSON, _ hall: DiningHall, _ type: String, _ menu: inout DiningMenu, _ open: inout Date?, _ close: inout Date?)
    {
        let formatter = sharedDateFormatter()
        open  = formatter.date(from: json[type + "_open" ].string ?? "")?.sameTimeToday()
        close = formatter.date(from: json[type + "_close"].string ?? "")?.sameTimeToday()
        
        menu = json[type + "_menu"].map{ (_, child) in parseDiningItem(child, hall) }
    }
    
    // Return a DiningMenu object parsed from JSON.
    private static func parseDiningItem(_ json: JSON, _ hall: DiningHall) -> DiningItem
    {
        let name = json["name"].stringValue
        
        var type: MealType
        switch json["meal"].stringValue 
        {
            case "Breakfast":   type = .breakfast
            case "Lunch":       type = .lunch
            case "Dinner":      type = .dinner
            case "Late Night":  type = .lateNight
            default:            type = .breakfast
        }
        
        return DiningItem(name: name, type: type, hall: hall)
    }
    
    private static func sharedDateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
}
