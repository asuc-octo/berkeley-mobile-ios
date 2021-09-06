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

// MARK: - KnownType

enum KnownType<T: RawRepresentable>: RawRepresentable {
    
    typealias RawValue = T.RawValue
    
    case known(type: T)
    case unknown(raw: RawValue)
    
    var rawValue: RawValue {
        switch self {
        case .known(let type):
            return type.rawValue
        case .unknown(let raw):
            return raw
        }
    }
    
    init?(rawValue: RawValue) {
        let type = T(rawValue: rawValue)
        if let type = type {
            self = .known(type: type)
        } else {
            self = .unknown(raw: rawValue)
        }
    }
}


// MARK: - MapMarkerType

/**
 Lists all recognized Map Marker Types, where the  `rawValue` is the Collection
 name on Firebase. Add to this enum to add another type of map resource.
 */
enum MapMarkerType: String, CaseIterable, Comparable {
    
    case restaurant = "Restaurant"
    case cafe = "Cafe"
    case store = "Store"
    case mentalHealth = "Mental Health"
    case garden = "Campus Garden"
    case bikes = "Lyft Bike"
    case lactation = "Lactation"
    case rest = "Rest"
    case microwave = "Microwave"
    case printer = "Printer"
    case water = "Water"
    case waste = "Waste"
    
    case none = "_none"
    
    static func < (lhs: MapMarkerType, rhs: MapMarkerType) -> Bool {
        // Compare marker types by their declaration order
        guard let lhsIdx = allCases.firstIndex(of: lhs), let rhsIdx = allCases.firstIndex(of: rhs) else {
            return true
        }
        return lhsIdx < rhsIdx
    }
    
    /** The icon to be shown on the map at the marker location  */
    func icon() -> UIImage {
        let icon: UIImage?
        switch self {
        case .microwave:
            icon = UIImage(named: "microwave-icon")?
                .withShadow()
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
            icon = UIImage(named: "water-bottle-icon")?
                .withShadow()
            break
        case .bikes:
            icon = UIImage(named: "bike-icon")?
                .withRoundedBorder(width: 3, color: .white)?
                .withShadow()
            break
        case .lactation:
            icon = UIImage(named: "lactation-icon")?
                .withShadow()
            break
        case .waste:
            icon = UIImage(named: "waste-icon")
            break
        case .garden:
            icon = UIImage(named: "garden-icon")?
                .withShadow()
            break
        case .cafe:
            icon = UIImage(named: "cafe-icon")?
                .withShadow()
            break
        case .store:
            icon = UIImage(named: "store-icon")?
                .withRoundedBorder(width: 3, color: .white)?
                .withShadow()
            break
        case .mentalHealth:
            icon = UIImage(named: "mental-health-icon")?
                .withShadow()
            break
        default:
            icon = UIImage(named: "Placemark")?
                .colored(Color.MapMarker.other)
            break
        }
        return (icon ?? UIImage()).resized(size: CGSize(width: 30, height: 30))
    }
    
    /** The color describing this marker type */
    func color() -> UIColor {
        switch self {
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
        case .store:
            return Color.MapMarker.store
        case .mentalHealth:
            return Color.MapMarker.mentalHealth
        default:
            return Color.MapMarker.other
        }
    }
    
}

// MARK: - MapMarker

/** Object describing resource locations (Microwaves, Bikes, Nap Pods, etc.) */
class MapMarker: NSObject, MKAnnotation, HasOpenTimes, SearchItem {
    
    var type: KnownType<MapMarkerType>
    
    var coordinate: CLLocationCoordinate2D
    @Display var title: String?
    @Display var subtitle: String?
    
    @Display var phone: String?
    @Display var email: String?
    @Display var address: String?
    var onCampus: Bool?

    var weeklyHours: WeeklyHours?
    var appointment: Bool?

    var mealPrice: String?
    var cal1Card: Bool?
    var eatWell: Bool?
    
    var searchName: String
    var location: (Double, Double)
    var locationName: String
    var icon: UIImage?
    var name: String

    init?(type: String,
          location: CLLocationCoordinate2D,
          name: String? = nil,
          description: String? = nil,
          address: String? = nil,
          onCampus: Bool? = nil,
          phone: String? = nil,
          email: String? = nil,
          weeklyHours: WeeklyHours? = nil,
          appointment: Bool? = nil,
          mealPrice: String? = nil,
          cal1Card: Bool? = nil,
          eatWell: Bool? = nil) {
        guard let type = KnownType<MapMarkerType>(rawValue: type) else { return nil }
        self.type = type
        self.coordinate = location
        self.title = name
        self.subtitle = description
        self.address = address
        self.onCampus = onCampus
        self.phone = phone
        self.email = email
        self.weeklyHours = weeklyHours
        self.mealPrice = mealPrice
        self.cal1Card = cal1Card
        self.eatWell = eatWell

        self.searchName = name ?? ""
        self.location = (location.latitude, location.longitude)
        self.locationName = address ?? ""
        self.icon = nil
        self.name = name ?? ""
    }
    
}
