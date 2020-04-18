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

// MARK: - MapMarkerType

/**
    Lists all Map Marker Types, where the  `rawValue` is the Collection
    name on Firebase. Add to this enum to add another type of map resource.
 */
enum MapMarkerType: String, CaseIterable {
    
    case mentalHealth = "Mental Health"
    case microwave = "Microwave"
    case napPod = "Nap Pod"
    case printer = "Printer"
    case water = "Water Fountain"
    case bikes = "Ford Go Bike"
    
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
    
    /** The color describing this marker type */
    func color() -> UIColor {
        switch self {
        case .mentalHealth:
            return UIColor(displayP3Red: 251/255, green: 210/255, blue: 0/255, alpha: 1.0)
        case .microwave:
            return UIColor(displayP3Red: 255/255, green: 114/255, blue: 9/255, alpha: 1.0)
        case .napPod:
            return UIColor(displayP3Red: 253/255, green: 43/255, blue: 168/255, alpha: 1.0)
        case .printer:
            return UIColor(displayP3Red: 93/255, green: 187/255, blue: 68/255, alpha: 1.0)
        case .water:
            return UIColor(displayP3Red: 62/255, green: 183/255, blue: 210/255, alpha: 1.0)
        case .bikes:
            return UIColor(displayP3Red: 45/255, green: 53/255, blue: 255/255, alpha: 1.0)
        }
    }
    
}

// MARK: - MapMarker

/** Object describing resource locations (Microwaves, Bikes, Nap Pods, etc.) */
class MapMarker: NSObject, MKAnnotation, HasOpenTimes {
    
    var type: MapMarkerType
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var phone: String?
    var address: String?
    var weeklyHours: WeeklyHours?
    
    init(type: MapMarkerType,
         location: CLLocationCoordinate2D,
         name: String? = nil,
         description: String? = nil,
         address: String? = nil,
         phone: String? = nil,
         weeklyHours: WeeklyHours? = nil) {
        self.type = type
        self.coordinate = location
        self.title = name
        self.subtitle = description
        self.address = address
        self.phone = phone
        self.weeklyHours = weeklyHours
    }
    
}
