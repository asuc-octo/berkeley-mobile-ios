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

fileprivate let kDiningHallsEndpoint = "https://asuc-mobile-dev.herokuapp.com/api/"
 + "dining_halls"

class DiningDataSource: ResourceDataSource
{
    typealias ResourceType = DiningHall
    
    // Fetch the list of dining halls and report back to the completionHandler.
    class func fetchResources(_ completion: @escaping (([Resource]?) -> Void)) 
    {
        Alamofire.request(encode_url_no_cache(kDiningHallsEndpoint)).responseJSON
        { response in
            
            if response.result.isFailure 
            {
                print("[Error @ DiningHallDataSource.getDiningHalls()]: request failed")
                return
            }
            
            let halls = JSON(data: response.data!)["dining_halls"].map { (_, child) in parseDiningHall(child) }
            completion(halls)
        } 
    }
    
    static func parseResource(_ json: JSON) -> Resource {
        return parseDiningHall(json)
    }
    
    // Return a DiningHall object parsed from JSON.
    static func parseDiningHall(_ json: JSON) -> DiningHall
    {
        let formatter = sharedDateFormatter()
        
        let name = json["name"].stringValue
        let link = json["image_link"].string
        
        let meals = MealType.allValues.reduce(MealMap()) 
        { (map, type) -> MealMap in
            
            let key   = type.rawValue
            let menu   = json[key + "_menu"].map{ (_, child) in parseDiningItem(child) }
            let open  = formatter.date(from: json[key + "_open" ].string ?? "")
            let close = formatter.date(from: json[key + "_close"].string ?? "")
            let shift = MealShift(menu: menu, hours: DateRange(start: open, end: close))
            
            var map = map
            map[type] = shift
            return map
        }
        
        let hall = DiningHall(name: name, imageLink: link, shifts: meals)
        FavoriteStore.shared.restoreState(for: hall)
        
        return hall
    }
    
    // Return a DiningMenu object parsed from JSON.
    private static func parseDiningItem(_ json: JSON) -> DiningItem
    {
        let name = json["name"].stringValue
        
        var type: MealType
        switch json["meal"].stringValue 
        {
            case "Breakfast":   type = .breakfast
            case "Lunch":       type = .lunch
            case "Dinner":      type = .dinner
            default:            type = .breakfast
        }
        
        let item = DiningItem(name: name, type: type)
        FavoriteStore.shared.restoreState(for: item)
        
        return item
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
