//
//  SortingFunctions.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import MapKit

class SortingFunctions {
    static func sortClose(loc1: HasLocation, loc2: HasLocation, location: CLLocation?, locationManager: CLLocationManager) -> Bool {
        var currLocation = location
        if location == nil {
            currLocation = locationManager.location
            if currLocation == nil {
                return true
            }
        }
        let d1 = loc1.getDistanceToUser(userLoc: currLocation!)
        let d2 = loc2.getDistanceToUser(userLoc: currLocation!)
        if d1 == d2 || d1.isNaN && d2.isNaN,
            let loc1 = loc1 as? SearchItem,
            let loc2 = loc2 as? SearchItem {
            return sortAlph(loc1: loc1, loc2: loc2)
        } else if d2.isNaN {
            return true
        } else if d1.isNaN {
            return false
        } else {
            return d1 < d2
        }
    }
    
    static func sortAlph(loc1: SearchItem, loc2: SearchItem) -> Bool {
        return loc1.searchName < loc2.searchName
    }
}
