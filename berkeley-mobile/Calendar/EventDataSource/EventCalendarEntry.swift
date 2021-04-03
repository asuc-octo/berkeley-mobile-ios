//
//  EventCalendarEntry.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

class EventCalendarEntry: CalendarEvent, HasImage, CanFavorite {
    // MARK: CalendarEvent Fields
    @Display var name: String
    var date: Date
    var end: Date?
    @Display var description: String?
    @Display var location: String?
    
    var additionalDescription: String {
        get {
            var desc = ""
            if let registerLink = self.registerLink {
                desc += "Register: " + registerLink.absoluteString + "\n"
            }
            if let sourceLink = self.sourceLink {
                desc += "Additional Info: " + sourceLink.absoluteString + "\n"
            }
            return desc
        }
    }
    
    // MARK: CanFavorite
    var isFavorited: Bool = false
    
    // MARK: HasImage
    var imageURL: URL?

    // MARK: Additional Fields
    /// The main category this event belongs to (e.g. Academic, Career) used to determine where it is displayed
    var category: String
    /// Link to register for the event
    var registerLink: URL?
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

    init(category: String, name: String, date: Date, description: String? = nil, location: String? = nil, registerLink: String? = nil, imageURL: String? = nil, sourceLink: String? = nil, type: String? = nil) {
        self.category = category
        self.name = name
        self.date = date
        self.description = description
        self.location = location
        self.registerLink = URL(string: registerLink ?? "")
        self.imageURL = URL(string: imageURL ?? "")
        self.sourceLink = URL(string: sourceLink ?? "")
        self.type = type
    }
}
