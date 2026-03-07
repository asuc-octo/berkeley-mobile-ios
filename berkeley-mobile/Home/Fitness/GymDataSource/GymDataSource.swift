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
                let gyms = querySnapshot!.documents.map { (doc) -> BMGym in
                    let dict = doc.data()
                    return parseGym(dict, docID: doc.documentID)
                }
                completion(gyms)
            }
        }
    }
    
    // Return a Gym object parsed from a dictionary.
    private static func parseGym(_ dict: [String: Any], docID: String) -> BMGym {
        let weeklyHours = BMGym.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        
        var gym = BMGym(name: dict["name"] as? String ?? "Unnamed",
                      description: dict["description"] as? String,
                      address: dict["address"] as? String,
                      phoneNumber: dict["phone"] as? String,
                      imageLink: dict["picture"] as? String,
                      weeklyHours: weeklyHours,
                      link: dict["link"] as? String,
                      documentID: docID)
        
        gym.latitude = dict["latitude"] as? Double
        gym.longitude = dict["longitude"] as? Double
        
        return gym
    }
}
