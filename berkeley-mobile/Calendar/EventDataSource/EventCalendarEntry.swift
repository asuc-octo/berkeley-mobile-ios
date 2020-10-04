//
//  EventCalendarEntry.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

class EventCalendarEntry: CalendarEvent {

    // MARK: CalendarEvent Fields

    var category: String
    var name: String
    var date: Date
    var end: Date?
    var description: String?
    var location: String?
    var link: URL?
    var imageURL: URL?
    var image: UIImage?
    var sourceLink: URL?

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
