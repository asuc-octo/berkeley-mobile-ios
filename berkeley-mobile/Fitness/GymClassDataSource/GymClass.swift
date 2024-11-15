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

    @Display var name: String
    var date: Date
    var end: Date?
    @Display var descriptionText: String?
    @Display var location: String?
    
    var additionalDescription: String {
        get {
            var desc = ""
            if let link = self.link {
                desc += "Link: " + link + "\n"
            }
            if let trainer = self.trainer {
                desc += "Trainer: " + trainer + "\n"
            }
            return desc
        }
    }

    // MARK: Additional Fields
    /// Link to zoom or website.
    var link: String?

    /// The trainer leading this gym class.
    @Display var trainer: String?

    /// The category for this class. See `GymClassType` for expected values.
    var type: String?

    /// The color associated with`type`. See `GymClassType` for provided colors.
    var color: UIColor {
        return GymClassType(rawValue: type ?? "")?.color ?? BMColor.eventDefault
    }

    init(name: String, start_time: Date, end_time: Date, class_type: String?, location: String?, link: String?, trainer: String?) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.date = start_time
        self.end = end_time
        self.type = class_type
        self.location = location
        self.link = link?.trimmingCharacters(in: .whitespacesAndNewlines)
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
