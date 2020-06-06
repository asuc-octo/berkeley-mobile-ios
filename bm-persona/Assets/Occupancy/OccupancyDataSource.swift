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

fileprivate let kOccupancySources: [DataSource.Type] = [
    LibraryDataSource.self,
    GymDataSource.self,
    DiningHallDataSource.self
]

class OccupancyDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the list of libraries and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let db = Firestore.firestore()
        db.collection(kOccupancyEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let requests = DispatchGroup()
                var occupancyObjects: [String: HasOccupancy & SearchItem] = [:]
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
                        let locationName = (document.documentID).lowercased().trimmingCharacters(in: .whitespaces)
                        if occupancyObjects[locationName] != nil {
                            occupancyObjects[locationName]!.occupancy = parseOccupancy(data: data)
                        }
                    }
                    completion([] as [Any])
                }
            }
        }
    }
    
    static func parseOccupancy(data: [String: Any]) -> Occupancy {
        var occupancyData: [DayOfWeek: [Int: Int]] = [:]
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
        return Occupancy(dailyOccupancy: occupancyData)
    }
}
