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
//fileprivate let kGymClassEndpoint = "https://asuc-mobile.herokuapp.com/api/group_exs"

var gymClassTypesSeen = [String]()

class GymClassDataSource: ResourceDataSource {
    
    internal static func parseResource(_ json: JSON) -> Resource {
        return parseGymClasses(json)
    }
    
    typealias ResourceType = GymClass
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchResources(_ completion: @escaping ([Resource]?) -> Void)
    {
        Alamofire.request(encode_url_no_cache(kGymClassEndpoint)).responseJSON
            { response in
                
                if response.result.isFailure
                {
                    print("[Error @ GymClassDataSource.fetchGyms()]: request failed")
                    return
                }
                var totalClasses: [GymClass] = []

                for (key, subJson) in JSON(data: response.data!) {
                    let gymClass = GymClass(name: key,
                                            class_type: key,
                                            location: "",
                                            trainer: "",
                                            date: nil,
                                            start_time: nil,
                                            end_time: nil,
                                            imageLink: subJson[0]["image_link"].stringValue)
                    totalClasses.append(gymClass)
                }
                for (_, subJson) in JSON(data: response.data!) {
                 let gymClasses = subJson.map { (_, child) in parseGymClasses(child) }
                totalClasses.append(contentsOf: gymClasses)
                }

                
                
                
                completion(totalClasses)
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
        
//        if !gymClassTypesSeen.contains(json["class_type"].stringValue){
//            gymClassTypesSeen.append(json["class_type"].stringValue)
            let gymClass = GymClass(name: json["name"].stringValue,
                                    class_type: json["class_type"].stringValue,
                                    location: json["location"].stringValue,
                                    trainer: json["trainer"].stringValue,
                                    date: date,
                                    start_time: start,
                                    end_time: end,
                                    imageLink: json["image_link"].stringValue)
            return gymClass
            
//        } else {
//            let gymClass = GymClass(name: "",
//                                    class_type: "",
//                                    location: "",
//                                    trainer: "",
//                                    date: Date(),
//                                    start_time: Date(),
//                                    end_time: Date(),
//                                    imageLink: "")
//            return gymClass
//        }
//

        
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
