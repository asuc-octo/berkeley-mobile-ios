//
//  GymClassDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate let kGymClassEndpoint = kAPIURL + "/group_exs"

class GymClassDataSource: ResourceDataSource {
    
    internal static func parseResource(_ json: JSON) -> Resource {
        return parseGymClasses(json)
    }
    
    typealias ResourceType = GymClass
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchResources(_ completion: @escaping ([Resource]?) -> Void)
    {
        Alamofire.request(kGymClassEndpoint).responseJSON
            { response in
                
                if response.result.isFailure
                {
                    print("[Error @ GymClassDataSource.fetchGyms()]: request failed")
                    return
                }
                
                let gymClasses = JSON(data: response.data!)["group_exs"].map { (_, child) in parseGymClasses(child) }
                
                
                
                completion(gymClasses)
        }
    }
    
    // Return a Gym object parsed from JSON.
    private static func parseGymClasses(_ json: JSON) -> GymClass
    {
        let formatter = sharedDateFormatter()
        let simpleFormatter = simpleDateFormatter()
        
        let date = simpleFormatter.date(from: json["date"].string ?? "")
        let start  = formatter.date(from: json["start_time"].string ?? "")
        let end = formatter.date(from: json["end_time"].string ?? "")

        let gymClass = GymClass(name: json["name"].stringValue, class_type: json["class_type"].stringValue, location: json["location"].stringValue, trainer: json["trainer"].stringValue, date: date,start_time: start, end_time: end, imageLink: "dsf")
        
        return gymClass
    }
    
    private static func sharedDateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PST")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
    
    private static func simpleDateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PST")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }



}