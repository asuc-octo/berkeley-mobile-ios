//
//  MapDataSource.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/21/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase
import MapKit

fileprivate let kMapEndpoint = "Map Marker"

class MapDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Calls the completion handler once markers of all types have finished parsing
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        var markers = [String: [MapMarker]]()
        let db = Firestore.firestore()
        db.collection(kMapEndpoint).getDocuments { (querySnapshot, err) in
            // Add sample marker
            let alertMarker2 = parseMarker([
                "tag": "Alert",
                "latitude": 37.86,
                "longitude": -122.25,
                "importanceLevel": 2,
                "address": "Sather Gate Importance 2"
            ])
            let alertMarker1 = parseMarker([
                "tag": "Alert",
                "latitude": 37.86,
                "longitude": -122.24,
                "importanceLevel": 1,
                "address": "Sather Gate Importance 1"
            ])
            let alertMarker0 = parseMarker([
                "tag": "Alert",
                "latitude": 37.86,
                "longitude": -122.23,
                "importanceLevel": 0,
                "address": "Sather Gate Importance 0"
            ])
            markers[alertMarker2!.type.rawValue, default:[]] += [alertMarker2!, alertMarker1!, alertMarker0!]
            if let err = err {
                print("[Error @ MapDataSource.fetchItems()]: \(err)")
            } else {
                querySnapshot!.documents.forEach { document in
                    let dict = document.data()
                    print("Map Marker : ", dict)
                    guard let marker = parseMarker(dict) else { return }
                    markers[marker.type.rawValue, default: []] += [marker]
                }
                completion([markers])
            }
        }
    }
    
    /** Return a MapMarker object parsed from a dictionary. */
    private static func parseMarker(_ dict: [String: Any]) -> MapMarker? {
        /* Obtain essential information for the tag
         * tag:                 Defines the label category of the map marker
         * latitude, longitude: Defines the marker location
         */
        guard let type = dict["tag"] as? String,
              let lat = dict["latitude"] as? Double, let lon = dict["longitude"] as? Double else {
            return nil
        }
        let cl = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let weeklyHours = MapMarker.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        return MapMarker(type: type,
                         location: cl,
                         name: dict["name"] as? String,
                         description: dict["description"] as? String,
                         address: dict["address"] as? String,
                         onCampus: dict["on_campus"] as? Bool,
                         importanceLevel: dict["importanceLevel"] as? Int,
                         phone: dict["phone"] as? String,
                         email: dict["email"] as? String,
                         weeklyHours: weeklyHours,
                         appointment: dict["by_appointment"] as? Bool,
                         mealPrice: dict["Average_Meal"] as? String,
                         cal1Card: dict["Cal1Card_Accepted"] as? Bool,
                         eatWell: dict["EatWell_Accepted"] as? Bool)
    }
}
