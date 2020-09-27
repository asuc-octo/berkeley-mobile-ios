//
//  AcademicCalendarEntry.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

/// An event on the Academic Calendar (e.g. 'First Day of Instruction').
class AcademicCalendarEntry: CalendarEvent {

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
        case "Holiday":
            return Color.eventHoliday
        case "Enrollment":
            return Color.eventAcademic
        default:
            return Color.eventDefault
        }
    }

    init(name: String, date: Date, description: String? = nil, location: String? = nil, type: String? = nil) {
        self.name = name
        self.date = date
        self.description = description
        self.location = location
        self.type = type
    }
}
