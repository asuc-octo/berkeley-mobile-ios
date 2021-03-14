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
    case rest = "Rest"
    case printer = "Printer"
    case water = "Water"
    case bikes = "Lyft Bike"
    case lactation = "Lactation"
    case waste = "Waste"
    case garden = "Campus Garden"
    case cafe = "Cafe"
    
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
        case .rest:
            icon = UIImage(named: "nap-pods-icon")?
                .withRoundedBorder(width: 3, color: .white)?
                .withShadow()
            break
        case .printer:
            icon = UIImage(named: "printer-icon")?
                .withRoundedBorder(width: 3, color: .white)?
                .withShadow()
            break
        case .water:
            icon = UIImage(named: "water-bottle-icon")
            break
        case .bikes:
            icon = UIImage(named: "bike-icon")?
                .withRoundedBorder(width: 3, color: .white)?
                .withShadow()
            break
        case .lactation:
            icon = UIImage(named: "lactation-icon")
            break
        case .waste:
            icon = UIImage(named: "waste-icon")
            break
        case .garden:
            icon = UIImage(named: "garden-icon")
            break
        case .cafe:
            icon = UIImage(named: "cafe-icon")
            break
        }
        return (icon ?? UIImage()).resized(size: CGSize(width: 30, height: 30))
    }
    
    /** The color describing this marker type */
    func color() -> UIColor {
        switch self {
        case .mentalHealth:
            return Color.MapMarker.mentalHealth
        case .microwave:
            return Color.MapMarker.microwave
        case .rest:
            return Color.MapMarker.rest
        case .printer:
            return Color.MapMarker.printer
        case .water:
            return Color.MapMarker.water
        case .bikes:
            return Color.MapMarker.bikes
        case .lactation:
            return Color.MapMarker.lactation
        case .waste:
            return Color.MapMarker.waste
        case .garden:
            return Color.MapMarker.garden
        case .cafe:
            return Color.MapMarker.cafe
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

    var mealPrice: String?
    
    init(type: MapMarkerType,
         location: CLLocationCoordinate2D,
         name: String? = nil,
         description: String? = nil,
         address: String? = nil,
         phone: String? = nil,
         weeklyHours: WeeklyHours? = nil,
         mealPrice: String? = nil) {
        self.type = type
        self.coordinate = location
        self.title = name
        self.subtitle = description
        self.address = address
        self.phone = phone
        self.weeklyHours = weeklyHours
        self.mealPrice = mealPrice
    }
    
}
