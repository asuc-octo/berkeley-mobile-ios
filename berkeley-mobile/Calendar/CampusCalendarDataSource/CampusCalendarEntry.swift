//
//  CalendarEntry.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

/// An event on the Campus-Wide Calendar.
class CampusCalendarEntry: CalendarEvent {

    // MARK: CalendarEvent Fields

    var name: String
    var date: Date
    var end: Date?
    var description: String?
    var location: String?

    // MARK: Additional Fields

    /// The category this event belongs to, if any.
    let type: String?

    /// The color associated with this event's `type`.
    var color: UIColor {
        guard let type = type else { return Color.eventDefault }
        switch type {
        case let type where type.contains("Exhibit"):
            return Color.eventExhibit
        case "Seminar":
            return Color.eventAcademic
        case "Lecture":
            return Color.eventAcademic
        case "Workshop":
            return Color.eventAcademic
        case "Course":
            return Color.eventAcademic
        default:
            return Color.eventDefault
        }
    }
    
    init(name: String, address: String?, date: Date, eventType: String) {
        self.name = name
        self.location = address
        self.date = date
        self.type = eventType
    }
}
