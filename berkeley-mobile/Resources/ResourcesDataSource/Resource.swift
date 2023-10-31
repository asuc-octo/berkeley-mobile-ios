//
//  ResourceEntry.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class Resource: SearchItem, HasLocation, HasOpenTimes {
    var icon: UIImage?
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }
    
    var locationName: String {
        return self.address ?? "Berkeley, CA"
    }
    
    var latitude: Double?
    var longitude: Double?
    
    @Display var name: String
    @Display var address: String?
    @Display var description: String?
    var weeklyHours: WeeklyHours?

    /// The category for this resource. See `ResourceType` for expected values.
    var type: String?

    /// The color associated with`type`. See `ResourceType` for provided colors.
    var color: UIColor {
        return ResourceType(rawValue: type ?? "")?.color ?? BMColor.eventDefault
    }
    
    init(name: String, address: String?, latitude: Double?, longitude: Double?, description: String?, hours: WeeklyHours?, type: String?) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.weeklyHours = hours
        self.type = type
    }
}
