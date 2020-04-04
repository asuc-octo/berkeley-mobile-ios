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

class MapDataSource: DataSource {
    
    // Calls the completion handler once markers of all types have finished parsing
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let markers = AtomicDictionary<String, [MapMarker]>()
        let requests = DispatchGroup()
        let db = Firestore.firestore()
        for query in MapMarkerType.allCases {
            requests.enter()
            db.collection(query.rawValue).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("[Error @ MapDataSource.fetchItems()]: \(err)")
                } else {
                    markers[query.rawValue] = querySnapshot!.documents.compactMap { (document) -> MapMarker? in
                        let dict = document.data()
                        return parseMarker(dict, type: query)
                    }
                }
                requests.leave()
            }
        }
        requests.notify(queue: .global(qos: .utility)) {
            completion(Array(markers.values))
        }
    }
    
    /** Return a MapMarker object parsed from a dictionary. */
    private static func parseMarker(_ dict: [String: Any], type: MapMarkerType) -> MapMarker? {
        guard let lat = dict["latitude"] as? Double, let lon = dict["longitude"] as? Double else {
            return nil
        }
        let cl = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        var weeklyHours: [DateInterval?]? = nil
        if let openClose = dict["open_close_array"] as? [[String: Any]] {
            weeklyHours = parseWeeklyTimes(openClose)
        }
        return MapMarker(type: type,
                         location: cl,
                         name: dict["name"] as? String,
                         description: dict["description"] as? String,
                         notes: dict["notes"] as? String,
                         phone: dict["phone"] as? String,
                         weeklyHours: weeklyHours)
    }
}
