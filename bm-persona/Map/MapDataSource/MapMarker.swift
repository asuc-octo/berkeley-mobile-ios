//
//  MapMarker.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum MapMarkerType: String, CaseIterable {
    
    case mentalHealth = "Mental Health Resources"
    case microwave = "Microwaves"
    case napPod = "Nap Pods"
    case printer = "Printers"
    case water = "Water Fountains"
    
    /** The icon to be shown on the map at the marker location  */
    func icon() -> UIImage {
        switch self {
        default:
            return UIImage()
        }
    }
    
}

/** Object describing resource locations (Microwaves, Bikes, Nap Pods, etc.) */
class MapMarker {
    
    var type: MapMarkerType
    var location: CLLocationCoordinate2D
    var name: String?
    var description: String?
    
    init(type: MapMarkerType, location: CLLocationCoordinate2D, name: String?, description: String?) {
        self.type = type
        self.location = location
        self.name = name
        self.description = description
    }
    
}
