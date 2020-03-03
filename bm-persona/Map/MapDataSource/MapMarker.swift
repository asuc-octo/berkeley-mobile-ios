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

/**
    Lists all Map Marker Types, where the  `rawValue` is the Collection
    name on Firebase. Add to this enum to add another type of map resource.
 */
enum MapMarkerType: String, CaseIterable {
    
    case mentalHealth = "Mental Health Resources"
    case microwave = "Microwaves"
    case napPod = "Nap Pods"
    case printer = "Printers"
    case water = "Water Fountains"
    case bikes = "Ford Go Bikes"
    
    /** The icon to be shown on the map at the marker location  */
    func icon() -> UIImage {
        let icon: UIImage?
        switch self {
        case .mentalHealth:
            icon = UIImage(named: "mental-health-icon")
            break
        case .microwave:
            icon = UIImage(named: "microwave-icon")
            break
        case .napPod:
            icon = UIImage(named: "nap-pods-icon")
            break
        case .printer:
            icon = UIImage(named: "printer-icon")
            break
        case .water:
            icon = UIImage(named: "water-bottle-icon")
            break
        case .bikes:
            icon = UIImage(named: "bike-icon")
            break
        }
        return (icon ?? UIImage()).resized(size: CGSize(width: 20, height: 20))
    }
    
}

/** Object describing resource locations (Microwaves, Bikes, Nap Pods, etc.) */
class MapMarker: NSObject, MKAnnotation {
    
    var type: MapMarkerType
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var notes: String?
    var phone: String?
    var weeklyHours: [DateInterval?]?
    
    init(type: MapMarkerType,
         location: CLLocationCoordinate2D,
         name: String? = nil,
         description: String? = nil,
         notes: String? = nil,
         phone: String? = nil,
         weeklyHours: [DateInterval?]? = nil) {
        self.type = type
        self.coordinate = location
        self.title = name
        self.subtitle = description
        self.notes = notes
        self.phone = phone
        self.weeklyHours = weeklyHours
    }
    
}
