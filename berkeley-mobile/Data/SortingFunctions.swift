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
    static func sortClose(loc1: HasLocation, loc2: HasLocation) -> Bool {
        let d1 = loc1.distanceToUser
        let d2 = loc2.distanceToUser
        if d1 == d2,
            let loc1 = loc1 as? SearchItem,
            let loc2 = loc2 as? SearchItem {
            return sortAlph(item1: loc1, item2: loc2)
        } else if d2 == nil {
            return true
        } else if d1 == nil {
            return false
        } else {
            return d1! < d2!
        }
    }
    
    static func sortAlph(item1: HasName, item2: HasName) -> Bool {
        return item1.name < item2.name
    }
}
