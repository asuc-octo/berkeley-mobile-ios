//
//  GymClassDataSource.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kGymClassesEndpoint = "Gyms/Gym Classes"
fileprivate let kDateLookahead = 7

class GymClassDataSource: DataSource {
    
    // Returns the list of collection names for the given date interval (inclusive). Must match the names on Firebase.
    private static func dateRangeCollections(interval: DateInterval) -> [String] {
        var collections = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var date = interval.start
        while date <= interval.end {
            collections.append(dateFormatter.string(from: date))
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                return collections
            }
            date = nextDate
        }
        return collections
    }
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let gymClasses = AtomicDictionary<String, [GymClass]>()
        let requests = DispatchGroup()
        let db = Firestore.firestore()
#if DEBUG
        // 2019-02-24
        let startDate = Date(timeIntervalSince1970: 1551024900)
#else
        let startDate = Date()
#endif
        guard let endDate = Calendar.current.date(byAdding: .day, value: kDateLookahead, to: startDate) else { return }
        for collection in dateRangeCollections(interval: DateInterval(start: startDate, end: endDate)) {
            requests.enter()
            db.document(kGymClassesEndpoint).collection(collection).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("[Error @ GymClassDataSource.fetchItems()]: \(err)")
                    return
                } else {
                    gymClasses[collection] = querySnapshot!.documents.map { (document) -> GymClass in
                        let dict = document.data()
                        return parseGymClasses(dict)
                    }
                }
                requests.leave()
            }
        }
        requests.notify(queue: .global(qos: .utility)) {
            completion(Array(gymClasses.values))
        }
    }
    
    // Return a GymClass object parsed from a dictionary.
    private static func parseGymClasses(_ dict: [String: Any]) -> GymClass {
        let start  = Date(timeIntervalSince1970: dict["start_time"] as? Double ?? 0)
        let end  = Date(timeIntervalSince1970: dict["end_time"] as? Double ?? 0)
        
        let gymClass = GymClass(name: dict["name"] as? String ?? "Unnamed",
                                start_time: start,
                                end_time: end,
                                class_type: dict["type"] as? String,
                                location: dict["room"] as? String,
                                trainer: dict["trainer"] as? String)
        return gymClass
    }
}
