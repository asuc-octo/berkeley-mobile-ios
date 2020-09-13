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
                .withRoundedBorder(width: 30, color: .white)?
                .withShadow(blur: 10, offset: CGSize(width: 0, height: 10))
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
            return UIColor(displayP3Red: 249/255, green: 180/255, blue: 35/255, alpha: 1.0)
        case .microwave:
            return UIColor(displayP3Red: 248/255, green: 95/255, blue: 73/255, alpha: 1.0)
        case .rest:
            return UIColor(displayP3Red: 253/255, green: 43/255, blue: 168/255, alpha: 1.0)
        case .printer:
            return UIColor(displayP3Red: 93/255, green: 187/255, blue: 68/255, alpha: 1.0)
        case .water:
            return UIColor(displayP3Red: 45/255, green: 121/255, blue: 176/255, alpha: 1.0)
        case .bikes:
            return UIColor(displayP3Red: 45/255, green: 53/255, blue: 255/255, alpha: 1.0)
        case .lactation:
            return UIColor(displayP3Red: 249/255, green: 134/255, blue: 49/255, alpha: 1.0)
        case .waste:
            return UIColor(displayP3Red: 101/255, green: 54/255, blue: 17/255, alpha: 1.0)
        case .garden:
            return UIColor(displayP3Red: 124/255, green: 190/255, blue: 49/255, alpha: 1.0)
        case .cafe:
            return UIColor(displayP3Red: 146/255, green: 83/255, blue: 163/255, alpha: 1.0)
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
