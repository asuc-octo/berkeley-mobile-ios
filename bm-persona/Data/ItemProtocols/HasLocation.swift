//
//  HasLocation.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import MapKit

protocol HasLocation {

    // MARK: Required

    /// The latitude of the conforming object.
    var latitude: Double? { get }

    /// The longitude of the conforming object.
    var longitude: Double? { get }

    /// The address of the conforming object.
    var address: String? { get }

    // MARK: Static Methods

    /// Returns a comparator used to compare two items by their distance to the user.
    static func locationComparator() -> ((HasLocation, HasLocation) -> Bool)

    /// Returns a closure that filters items by their distance to the user.
    static func locationFilter(by maxDistance: Double) -> ((HasLocation) -> Bool)
    
}

extension HasLocation {

    /// Returns the distance to the user in miles if possible, otherwise `nil`.
    var distanceToUser: Double? {
        guard let location = LocationManager.shared.userLocation else { return nil }
        if let lat = latitude, let lon = longitude, lat != Double.nan, lon != Double.nan {
            let itemLocation = CLLocation(latitude: lat, longitude: lon)
            let meters = location.distance(from: itemLocation)
            let measurement = Measurement(value: meters, unit: UnitLength.meters)
            let miles = measurement.converted(to: UnitLength.miles).value
            return miles
        }
        return nil
    }

    static func locationComparator() -> ((HasLocation, HasLocation) -> Bool) {
        return SortingFunctions.sortClose(loc1:loc2:)
    }

    static func locationFilter(by maxDistance: Double) -> ((HasLocation) -> Bool) {
        return { item in
            if let distance = item.distanceToUser, distance <= maxDistance {
                return true
            }
            return false
        }
    }
}
