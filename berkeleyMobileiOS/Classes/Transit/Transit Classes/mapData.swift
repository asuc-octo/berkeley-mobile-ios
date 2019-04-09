//
//  mapData.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 12/2/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore


struct MapState {
    
    var cachedMarkers: [mapMarker] = []
    var shortcutButtons: [UIButton] = []
    //Create shortcut buttons and store them on init
    init() {
        let shortcutImages = ["printer-icon", "nap-pod-icon", "mental-health-icon", "water-bottle-icon", "microwave-icon"]
        for i in 0...4 {
            let newButton = UIButton()
            newButton.setImage(UIImage(named: shortcutImages[i]), for: .normal)
            newButton.tag = i
            shortcutButtons.append(newButton)
        }
    }
}

struct mapMarker {
    let type: String
    let name: String
    let coordinates: (Float, Float)
}

struct shortcut {
    let text: String
    let icon: UIImage
}

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
