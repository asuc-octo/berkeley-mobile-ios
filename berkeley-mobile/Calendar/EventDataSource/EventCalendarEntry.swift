//
//  EventCalendarEntry.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

class EventCalendarEntry: CalendarEvent, HasImage {

    // MARK: CalendarEvent Fields
    var name: String
    var date: Date
    var end: Date?
    var description: String?
    var location: String?

    // MARK: Additional Fields
    
    /// The main category this event belongs to (e.g. Academic, Career) used to determine where it is displayed
    var category: String
    /// Link to the event
    var link: URL?
    var imageURL: URL?
    /// Link to where the event was found
    var sourceLink: URL?
    /// The subcategory for the event within the main category
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

    init(category: String, name: String, date: Date, description: String? = nil, location: String? = nil, link: String? = nil, imageURL: String? = nil, sourceLink: String? = nil, type: String? = nil) {
        self.category = category
        self.name = name
        self.date = date
        self.description = description
        self.location = location
        self.link = URL(string: link ?? "")
        self.imageURL = URL(string: imageURL ?? "")
        self.sourceLink = URL(string: sourceLink ?? "")
        self.type = type
    }
}