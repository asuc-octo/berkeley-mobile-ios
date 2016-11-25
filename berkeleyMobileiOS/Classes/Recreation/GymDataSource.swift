//
//  GymDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate let kGymsEndpoint = kAPIURL + "/gyms"

class GymDataSource: NSObject {
    typealias completionHandler = (_ halls: [Gym]?) -> Void
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchGyms(_ completion: @escaping completionHandler)
    {
        Alamofire.request(kGymsEndpoint).responseJSON
            { response in
                
                if response.result.isFailure {
                    print("[Error @ GymDataSource.fetchGyms()]: request failed")
                    return
                }
                
                let gyms = JSON(data: response.data!)["gyms"].map { (_, child) in parseGym(child) }
                completion(gyms)
        }
    }
    
    // Return a Gym object parsed from JSON.
    private static func parseGym(_ json: JSON) -> Gym
    {
        let formatter = sharedDateFormatter()
        let open  = formatter.date(from: json["opening_time_today"].string ?? "")
        let close = formatter.date(from: json["closing_time_today"].string ?? "")
        
        let gym = Gym(name: json["name"].stringValue,
                      address: json["address"].stringValue,
                      imageLink: json["image_link"].stringValue,
                      openingTimeToday: open,
                      closingTimeToday: close)
        
        return gym
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
