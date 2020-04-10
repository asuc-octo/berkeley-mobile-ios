//
//  GymClass.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class GymClass {
    
    let name: String
    
    var start_time: Date
    var end_time: Date
    
    var class_type: String?
    var location: String?
    var trainer: String?
    
    var color: UIColor {
        return GymClassType(rawValue: class_type ?? "")?.color ?? Color.eventDefault
    }

    init(name: String, start_time: Date, end_time: Date, class_type: String?, location: String?, trainer: String?) {
        self.name = name
        self.start_time = start_time
        self.end_time = end_time
        self.class_type = class_type
        self.location = location
        self.trainer = trainer
    }
    
    /** Returns a string describing a given list of components of a `GymClass`, separated by ` / `. */
    func description(components: [GymClassDescriptor]) -> String {
        return components.compactMap({ $0.describing(self) }).joined(separator: " / ")
    }
}

/** Aids in modularized string representation of GymClasses */
enum GymClassDescriptor {
    
    case date
    case startTime
    case duration
    case location
    
    func describing(_ gymClass: GymClass) -> String? {
        let dateFormatter = DateFormatter()
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.unitsStyle = .short
        componentsFormatter.allowedUnits = [.hour, .minute]
        
        switch self {
        case .date:
            dateFormatter.dateFormat = "MMM d"
            return dateFormatter.string(from: gymClass.start_time)
        case .startTime:
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: gymClass.start_time)
        case .duration:
            return componentsFormatter.string(from: gymClass.start_time, to: gymClass.end_time)
        case .location:
            return gymClass.location
        }
    }
    
}
