//
//  ResourceEntry.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class ResourceEntry: SearchItem {
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (self.latitude, self.longitude)
    }
    
    var locationName: String {
        return self.campusLocation ?? "N/A"
    }
    
    var description: String {
        return self.desc
    }
    
    let name: String
    let campusLocation: String?
    let latitude: Double
    let longitude: Double
    let desc: String
    
    init(name: String, campusLocation: String, latitude: Double, longitude: Double, description: String) {
        self.name = name
        self.campusLocation = campusLocation
        self.latitude = latitude
        self.longitude = longitude
        self.desc = description
    }
}
