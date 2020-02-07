//
//  CalendarEntry.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class CalendarEntry: SearchItem {
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (0, 0)
    }
    
    var locationName: String {
        return campusLocation ?? "N/A"
    }
    
    let name: String
    let campusLocation: String?
    let date: Date?
    let eventType: String?
    
    init(name: String, campusLocation: String, date: Date, eventType: String) {
        self.name = name
        self.campusLocation = campusLocation
        self.date = date
        self.eventType = eventType
    }
    
}
