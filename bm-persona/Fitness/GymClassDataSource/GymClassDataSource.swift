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
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // Returns the list of collection names for the given date interval (inclusive). Must match the names on Firebase.
    private static func dateRangeCollections(interval: DateInterval) -> [String] {
        var collections = [String]()
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
                    gymClasses[collection] = querySnapshot!.documents.compactMap { (document) -> GymClass? in
                        guard let date = dateFormatter.date(from: collection) else { return nil }
                        let dict = document.data()
                        return parseGymClasses(dict, date: date)
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
    private static func parseGymClasses(_ dict: [String: Any], date: Date) -> GymClass? {
        // Gym Class start and end times in Firebase have date of when scraper was run.
        guard let start_time = dict["start_time"] as? Double,
              let end_time = dict["end_time"] as? Double,
              let start = Date(timeIntervalSince1970: start_time).sameTime(on: date),
              var end = Date(timeIntervalSince1970: end_time).sameTime(on: date) else {
                return nil
        }
        // Case when interval contans midnight - end time is in next day.
        if end < start {
            let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: end)
            end = Calendar.current.nextDate(after: start, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? Date.distantPast
            if end < start {
                return nil
            }
        }
        
        let gymClass = GymClass(name: dict["name"] as? String ?? "Unnamed",
                                start_time: start,
                                end_time: end,
                                class_type: dict["type"] as? String,
                                location: dict["room"] as? String,
                                trainer: dict["trainer"] as? String)
        return gymClass
    }
}
