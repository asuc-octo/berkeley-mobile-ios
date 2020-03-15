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
    
    var latitude: Double { get }
    var longitude: Double { get }
    func getDistanceToUser(userLoc: CLLocation?) -> Double
    static var nearbyDistance: Double { get }
    static var invalidDistance: Double { get }
    
}

extension HasLocation {
    
    func getDistanceToUser(userLoc: CLLocation?) -> Double {
        if !latitude.isNaN && !longitude.isNaN && userLoc != nil {
            let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distance = round(userLoc!.distance(from: itemLocation) / 1600.0 * 10) / 10
            return distance
        }
        return Double.nan
    }
}
