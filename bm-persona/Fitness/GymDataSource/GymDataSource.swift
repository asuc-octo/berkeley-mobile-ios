//
//  GymDataSource.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kGymsEndpoint = "Gyms"

class GymDataSource: DataSource
{
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
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
    
    // Return a Gym object parsed from a dictionary.
    private static func parseGym(_ dict: [String: Any]) -> Gym {
        let weeklyHours = Gym.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        
        let gym = Gym(name: dict["name"] as? String ?? "Unnamed",
                      address: dict["address"] as? String,
                      phoneNumber: dict["phone"] as? String,
                      imageLink: dict["picture"] as? String,
                      weeklyHours: weeklyHours)
        
        gym.latitude = dict["latitude"] as? Double
        gym.longitude = dict["longitude"] as? Double
        
        return gym
    }
}
