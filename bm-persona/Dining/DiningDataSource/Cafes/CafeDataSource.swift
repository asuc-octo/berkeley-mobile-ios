//
//  CafeDataSource.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCafeEndpoint = "Cafes"

class CafeDataSource: DataSource {
    
    // Returns the collection name for the given date. Must match the name on Firebase.
    private static func collectionForDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // Fetch the list of Dining Halls and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        var cafes = [String: Cafe]()
        let requests = DispatchGroup()
        requests.enter()
        let db = Firestore.firestore()
        db.collection(kCafeEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ CafeDataSource.fetchItems()]: \(err)")
            } else {
                querySnapshot!.documents.forEach { (document) in
                    let dict = document.data()
                    cafes[document.documentID] = parseCafe(dict)
                }
            }
            requests.leave()
        }
        requests.notify(queue: .global(qos: .utility)) {
            completion(Array(cafes.values))
        }
    }
    
    // Return a Cafe object parsed from a dictionary.
    private static func parseCafe(_ dict: [String: Any]) -> Cafe {
        let weeklyHours = Cafe.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        let cafe = Cafe(name: dict["name"] as? String ?? "Unnamed",
                                  campusLocation: dict["address"] as? String,
                                  phoneNumber: dict["phone"] as? String,
                                  imageLink: dict["picture"] as? String,
                                  shifts: MealMap(),
                                  hours: weeklyHours,
                                  latitude: dict["latitude"] as? Double,
                                  longitude: dict["longitude"] as? Double)
        
        let breakfast = parseDiningMenu(dict["Breakfast"] as? [Any] ?? [])
        let lunch = parseDiningMenu(dict["Lunch"] as? [Any] ?? [])
        
        cafe.meals["Breakfast"] = breakfast
        cafe.meals["Lunch"] = lunch
        return cafe
    }
    
    // Return a MealMap object parsed from a dictionary.
    private static func parseDiningMenu(_ dict: [Any]) -> CafeMenu {
        var menu = CafeMenu()
        for item in dict {
            if let item = item as? [String: Any] {
                // TODO: - Backend doesn't have food restrictions
                menu.append(CafeItem(name: item["name"] as? String ?? "", cost: item["cost"] as? Double ?? 0.0, restrictions: item["food_types"] as? [String] ?? []))
            }
        }
        return menu
    }
}
