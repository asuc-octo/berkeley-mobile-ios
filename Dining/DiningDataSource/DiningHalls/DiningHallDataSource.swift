//
//  DiningHallDataSource.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//
import Foundation
import Firebase

fileprivate let kDiningHallEndpoint = "Dining Halls"

class DiningHallDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Returns the collection name for the given date. Must match the name on Firebase.
    private static func collectionForDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // Fetch the list of Dining Halls and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        var diningHalls = [String: DiningHall]()
        let requests = DispatchGroup()
        requests.enter()
        let db = Firestore.firestore()
        db.collection(kDiningHallEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("[Error @ DiningHallDataSource.fetchItems()]: \(err)")
            } else {
                querySnapshot!.documents.forEach { (document) in
                    let dict = document.data()
                    diningHalls[document.documentID] = parseDiningHall(dict)
                }
            }
            requests.leave()
        }
        requests.notify(queue: .global(qos: .utility)) {
            fetchMenus(diningHalls, completion: completion)
        }
    }
    
    static func fetchMenus(_ diningHalls: [String: DiningHall], completion: @escaping DataSource.completionHandler) {
        let collectionToday = collectionForDate(Date())
        
        let requests = DispatchGroup()
        let db = Firestore.firestore()
        for (documentID, diningHall) in diningHalls {
            requests.enter()
            db.collection(kDiningHallEndpoint)
                .document(documentID)
                .collection(collectionToday).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("[Error @ DiningHallDataSource.fetchMenus()]: \(err)")
                } else {
                    querySnapshot!.documents.forEach { (document) in
                        let dict = document.data()
                        diningHall.meals[document.documentID] = parseDiningMenu(dict)
                    }
                }
                requests.leave()
            }
        }
        requests.notify(queue: .global(qos: .utility)) {
            completion(Array(diningHalls.values))
        }
    }
    
    // Return a DiningHall object parsed from a dictionary.
    private static func parseDiningHall(_ dict: [String: Any]) -> DiningHall {
        let weeklyHours = DiningHall.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        let diningHall = DiningHall(name: dict["name"] as? String ?? "Unnamed",
                                  address: dict["address"] as? String,
                                  phoneNumber: dict["phone"] as? String,
                                  imageLink: dict["picture"] as? String,
                                  shifts: MealMap(),
                                  hours: weeklyHours,
                                  latitude: dict["latitude"] as? Double,
                                  longitude: dict["longitude"] as? Double)
        return diningHall
    }
    
    // Return a MealMap object parsed from a dictionary.
    private static func parseDiningMenu(_ dict: [String: Any]) -> DiningMenu {
        var menu = DiningMenu()
        if let items = dict["items"] as? [[String: Any]] {
            menu = items.compactMap { (item) -> DiningItem? in
                if let name = (item["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    if name.count > 1 && !name.hasPrefix("Cal Dining") {
                        // Removes occasional "." and garbage data from backend
                        return DiningItem(name: name, restrictions: item["food_types"] as? [String] ?? [])
                    }
                }
                return nil
            }
        }
        return menu
    }
}
