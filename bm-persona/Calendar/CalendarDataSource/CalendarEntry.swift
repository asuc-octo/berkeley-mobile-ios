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
    var icon: UIImage?
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (0, 0)
    }
    
    var locationName: String {
        return address ?? "N/A"
    }
    
    var description: String {
        return ""
    }
    
    let name: String
    let address: String?
    let date: Date?
    let eventType: String?
    
    init(name: String, address: String, date: Date, eventType: String) {
        self.name = name
        self.address = address
        self.date = date
        self.eventType = eventType
    }
    
}
