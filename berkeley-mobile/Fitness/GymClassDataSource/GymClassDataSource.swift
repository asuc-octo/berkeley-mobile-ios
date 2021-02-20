//
//  GymClassDataSource.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kGymClassesEndpoint = "Gym Classes"

class GymClassDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let now = Date()
        let db = Firestore.firestore()
        db.collection(kGymClassesEndpoint).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("[Error @ GymClassDataSource.fetchItems()]: \(err)")
                return
            } else {
                let gymClasses = querySnapshot!.documents.map { (document) -> [GymClass] in
                    let dict = document.data()
                    return dict.values.compactMap { (val) -> GymClass? in
                        guard let classDict = val as? [String: Any] else { return nil }
                        let gymClass = parseGymClass(classDict)
                        // Only return classes that have yet to finish.
                        return (gymClass?.end ?? Date.distantPast) > now ? gymClass : nil
                    }
                }
                completion(gymClasses)
            }
        }
    }
    
    // Return a GymClass object parsed from a dictionary.
    private static func parseGymClass(_ dict: [String: Any]) -> GymClass? {
        // Drop classes with unknown start / end times
        guard let time = dict["open_close_array"] as? [String: Any],
              let start_time = time["open_time"] as? Double,
              let end_time = time["close_time"] as? Double else {
                return nil
        }
        
        let gymClass = GymClass(name: dict["class"] as? String ?? "Unnamed",
                                start_time: Date(timeIntervalSince1970: start_time),
                                end_time: Date(timeIntervalSince1970: end_time),
                                class_type: dict["class type"] as? String,
                                location: dict["location"] as? String,
                                link: dict["link"] as? String,
                                trainer: dict["trainer"] as? String)
        return gymClass
    }
}
