//
//  CafeDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Nabeel Mamoon on 2/5/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import Foundation

import UIKit
import Foundation

import Alamofire
import SwiftyJSON

fileprivate let kCafesEndpoint = "http://asuc-mobile-dev.herokuapp.com/api/cafes"

class CafeDataSource: ResourceDataSource
{
    typealias ResourceType = CafeClass
    
    // Fetch the list of dining halls and report back to the completionHandler.
    class func fetchResources(_ completion: @escaping (([Resource]?) -> Void))
    {
        Alamofire.request(encode_url_no_cache(kCafesEndpoint)).responseJSON
            { response in
                
                if response.result.isFailure
                {
                    print("[Error @ DiningHallDataSource.getDiningHalls()]: request failed")
                    return
                }
                
                print("CAFES PULL")
                
                let halls = JSON(data: response.data!)["cafes"].map { (_, child) in parseDiningHall(child) }
                
                print("CAFES PULL SUCCEEDED 1")
                completion(halls)
                
                print("CAFES PULL SUCCEEDED 2")
        }
    }
    
    static func parseResource(_ json: JSON) -> Resource {
        return parseDiningHall(json)
    }
    
    // Return a DiningHall object parsed from JSON.
    static func parseDiningHall(_ json: JSON) -> CafeClass
    {
        let formatter = sharedDateFormatter()
        
        let name = json["name"].stringValue
        let link = json["image_link"].string
        
        print("SHOULDPRINT")
        
        print("CAFELINK" + link!)
        print("CAFENAME" + name)
        
        let meals = MealType.allValues.reduce(MealMap())
        { (map, type) -> MealMap in
            
            let key   = type.rawValue
            var meal_int = 0
            switch type
            {
            case .breakfast:   meal_int = 0
            case .lunch:       meal_int = 1
            case .dinner:      meal_int = 2
            default:            meal_int = 0
            }
            let menu   = json["menus"][meal_int]["menu_items"].map{ (_, child) in parseDiningItem(child) }
            let open  = formatter.date(from: json["menus"][meal_int]["start_time" ].string ?? "")
            let close = formatter.date(from: json["menus"][meal_int]["end_time"].string ?? "")
            let shift = MealShift(menu: menu, hours: DateRange(start: open, end: close))
            
            var map = map
            map[type] = shift
            return map
        }
        
        let hall = CafeClass(name: name, imageLink: link, shifts: meals)
        FavoriteStore.shared.restoreState(for: hall)
        
        return hall
    }
    
    // Return a DiningMenu object parsed from JSON.
    private static func parseDiningItem(_ json: JSON) -> DiningItem
    {
        let name = json["name"].stringValue
        let restrictions: [String] = json["food_type"].arrayValue.map {$0.stringValue}
        
        var type: MealType
        switch json["meal"].stringValue
        {
        case "Breakfast":   type = .breakfast
        case "Lunch":       type = .lunch
        case "Dinner":      type = .dinner
        default:            type = .breakfast
        }
        
        let item = DiningItem(name: name, type: type, restrictions: restrictions)
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
