//
//  OccupancyDataSource.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/17/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kOccupancyEndpoint = "Occupancy"

// data sources for locations that have an occupancy associated with them
// necessary to load these objects from Firebase before occupancy data
fileprivate let kOccupancySources: [DataSource.Type] = [
    LibraryDataSource.self,
    GymDataSource.self,
    DiningHallDataSource.self
]

class OccupancyDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // fetch occupancy data and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let db = Firestore.firestore()
        db.collection(kOccupancyEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let requests = DispatchGroup()
                var occupancyObjects: [String: HasOccupancy & SearchItem] = [:]
                // make sure all objects with an associated occupancy are loaded first (library, dining hall, gym)
                // need to do this first because this data source sets the occupancy for each instance of a library, gym, etc.
                for source in kOccupancySources {
                    requests.enter()
                    DataManager.shared.fetch(source: source) { objects in
                        if let tmp = objects as? [HasOccupancy & SearchItem] {
                            for object in tmp {
                                let name = (object.searchName).lowercased().trimmingCharacters(in: .whitespaces)
                                occupancyObjects[name] = object
                            }
                        }
                        requests.leave()
                    }
                }
                requests.notify(queue: .global(qos: .utility)) {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        // only way to match occupancy with an object right now seeing if the names match
                        let locationName = (document.documentID).lowercased().trimmingCharacters(in: .whitespaces)
                        if var object = occupancyObjects[locationName] {
                            object.occupancy = parseOccupancy(data: data)
                        }
                    }
                    completion([] as [Any])
                }
            }
        }
    }
    
    // parse occupancy data from Firebase into an occupancy object
    static func parseOccupancy(data: [String: Any]) -> Occupancy {
        var occupancyData: [DayOfWeek: [Int: Int]] = [:]
        var liveOccupancy: Int?
        for key in data.keys {
            var dayOfWeek: DayOfWeek? = nil
            switch key {
            case "Sa":
                dayOfWeek = DayOfWeek.saturday
            case "Su":
                dayOfWeek = DayOfWeek.sunday
            case "Mo":
                dayOfWeek = DayOfWeek.monday
            case "Tu":
                dayOfWeek = DayOfWeek.tuesday
            case "We":
                dayOfWeek = DayOfWeek.wednesday
            case "Th":
                dayOfWeek = DayOfWeek.thursday
            case "Fr":
                dayOfWeek = DayOfWeek.friday
            case "live":
                #if DEBUG
                liveOccupancy = data[key] as? Int ?? Int.random(in: 0...100)
                #else
                liveOccupancy = data[key] as? Int
                #endif
            default:
                break
            }
            if dayOfWeek != nil, let hours = data[key] as? [[String: Int]] {
                occupancyData[dayOfWeek!] = [:] as [Int: Int]
                for hourOccupancy in hours {
                    if let hour = hourOccupancy["hour"], let percent = hourOccupancy["occupancyPercent"] {
                        occupancyData[dayOfWeek!]![hour] = percent
                    }
                }
            }
        }
        return Occupancy(dailyOccupancy: occupancyData, live: liveOccupancy)
    }
}
