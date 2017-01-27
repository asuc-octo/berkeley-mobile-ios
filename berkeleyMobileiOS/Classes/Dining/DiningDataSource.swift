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
        Alamofire.request(kDiningHallsEndpoint).responseJSON
        { response in
            
            if response.result.isFailure {
                print("[Error @ DiningHallDataSource.getDiningHalls()]: request failed")
                return
            }
            
            let halls = JSON(data: response.data!)["dining_halls"].map { (_, child) in parseDiningHall(child) }
            completion(halls)
        }
    }
    
    // Return a DiningHall object parsed from JSON.
    private static func parseDiningHall(_ json: JSON) -> DiningHall
    {
        let formatter = sharedDateFormatter()
        let hall = DiningHall(name: json["name"].stringValue, url: json["image_link"].stringValue)

        for type in MealType.allValues
        {
            let key = type.rawValue
            let shift = hall.meals[type]!
            
            shift.menu  = json[key + "_menu"].map{ (_, child) in parseDiningItem(child, hall) }
            shift.open  = formatter.date(from: json[key + "_open" ].string ?? "")?.sameTimeToday()
            shift.close = formatter.date(from: json[key + "_close"].string ?? "")?.sameTimeToday()
        }
        
        return hall
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
