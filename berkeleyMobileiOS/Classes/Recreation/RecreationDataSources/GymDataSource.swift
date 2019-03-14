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
import Firebase

fileprivate let kGymsEndpoint = "Gyms"

class GymDataSource: ResourceDataSource 
{
    typealias ResourceType = Gym
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchResources(_ completion: @escaping ([Resource]?) -> Void)
    {
        
        let db = Firestore.firestore()
        db.collection(kGymsEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ GymDataSource.fetchGyms()]: \(err)")
                return
            } else {
                let gyms = querySnapshot!.documents.map { (document) -> Gym in
                    let dict = document.data()
                    return parseGym(dict)
                }
                completion(gyms)
            }
        }
    }
    
    static func parseResource(_ json: JSON) -> Resource {
        return parseGym(json.dictionaryObject ?? [:])
    }
    
    // Return a Gym object parsed from a dictionary.
    private static func parseGym(_ dict: [String: Any]) -> Gym {
        let weeklyHours = parseWeeklyTimes(dict["open_close_array"] as? [[String: Any]])
        let timesToday = weeklyHours[Date().weekday()]
        
        let gym = Gym(name: dict["name"] as? String ?? "Unnamed",
                      address: dict["address"] as? String,
                      phoneNumber: dict["phone"] as? String,
                      imageLink: dict["picture"] as? String,
                      openingTimeToday: timesToday?.start,
                      closingTimeToday: timesToday?.end)
        
        gym.latitude = dict["latitude"] as? Double
        gym.longitude = dict["longitude"] as? Double
        
        FavoriteStore.shared.restoreState(for: gym)
        
        return gym
    }
}
