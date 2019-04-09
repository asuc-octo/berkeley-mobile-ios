//
//  mapMarkerDataSource.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 12/2/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import Foundation
import FirebaseFirestore

class mapMarkerDataSource {
    static let queries = ["Mental Health", "Microwave", "Nap Pod", "Printer", "Water Fountain"]
    static var markers: [String: [mapMarker]] = [:]
    static let db = Firestore.firestore()
    static func fetchAllMarkerData() {
        markers = [:]
        for query in queries {
            markers[query] = []
            fetchData(query)
        }
        
    }
    
    static func fetchData(_ query: String) {
        db.collection(query).getDocuments() { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    if let location = data["location"] as? String, let lat = data["lat"] as? Float, let lon = data["lon"] as? Float,
                        var markerArray = markers[query] {

                        let marker = mapMarker(type: query, name: location, coordinates: (lat, lon))
                        markerArray.append(marker)
                    }
                }
            }
        }
    }
}
