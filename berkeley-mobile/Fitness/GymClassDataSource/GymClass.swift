//
//  GymClass.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class GymClass: CalendarEvent {

    // MARK: CalendarEvent Fields

    var name: String
    var date: Date
    var end: Date?
    var description: String?
    var location: String?
    var website_link: String?

    // MARK: Additional Fields

    /// The trainer leading this gym class.
    var trainer: String?

    /// The category for this class. See `GymClassType` for expected values.
    var type: String?

    /// The color associated with`type`. See `GymClassType` for provided colors.
    var color: UIColor {
        return GymClassType(rawValue: type ?? "")?.color ?? Color.eventDefault
    }

    init(name: String, start_time: Date, end_time: Date, class_type: String?, location: String?, website_link: String?, trainer: String?) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.date = start_time
        self.end = end_time
        self.type = class_type
        self.location = location
        self.website_link = website_link?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.trainer = trainer?.trimmingCharacters(in: .whitespacesAndNewlines)
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
            return dateFormatter.string(from: gymClass.date)
        case .startTime:
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: gymClass.date)
        case .duration:
            guard let end = gymClass.end else { return nil }
            return componentsFormatter.string(from: gymClass.date, to: end)
        case .location:
            return gymClass.location
        }
    }
    
}
