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
            if let err = err {
                print("[Error @ MapDataSource.fetchItems()]: \(err)")
            } else {
                querySnapshot!.documents.forEach { document in
                    let dict = document.data()
                    guard let marker = parseMarker(dict) else { return }
                    markers[marker.type.rawValue, default: []] += [marker]
                }
                completion([markers])
            }
        }
    }
    
    /** Return a MapMarker object parsed from a dictionary. */
    private static func parseMarker(_ dict: [String: Any]) -> MapMarker? {
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
                         phone: dict["phone"] as? String,
                         email: dict["email"] as? String,
                         weeklyHours: weeklyHours,
                         appointment: dict["by_appointment"] as? Bool,
                         mealPrice: dict["Average_Meal"] as? String,
                         cal1Card: dict["Cal1Card_Accepted"] as? Bool,
                         eatWell: dict["EatWell_Accepted"] as? Bool,
                         mpdRooms: getMPDRooms(type: type, dict: dict),
                         accessibleGIRs: dict["accessibleGIRs"] as? [String],
                         nonAccesibleGIRs: dict["nonAccessibleGIRs"] as? [String])
    }
    
    private static func getMPDRooms(type: String, dict: [String: Any]) -> [BMMPDRoomInfo]? {
        if type == "Menstrual Products" {
            guard let rooms = dict["rooms"] as? [[String: Any]] else { return nil}
            var newRoomInfos = [BMMPDRoomInfo]()
            for room in rooms {
                newRoomInfos.append(BMMPDRoomInfo(bathroomType: room["bathroomType"] as? String ?? "", productType: room["productType"] as? String ?? "", floorName: room["floorName"] as? String ?? "", roomNumber: room["roomNumber"] as? String ?? ""))
            }
           return newRoomInfos
        }
        return nil
    }
}
