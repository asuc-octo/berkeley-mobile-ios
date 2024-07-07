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
    // FIXME: category should be more suited as an enum
    //var category: String
    /// Link to register for the event
    var registerLink: URL?
    /// Link to where the event was found
    var sourceLink: URL?
    /// The subcategory for the event within the main category
    let type: String?

    /// The color associated with this event's `type`.
    var color: UIColor {
        guard let type = type else { return BMColor.eventDefault }
        switch type {
        case "Holiday":
            return BMColor.eventHoliday
        case "Enrollment":
            return BMColor.eventAcademic
        default:
            return BMColor.eventDefault
        }
    }

    init(name: String, date: Date, end: Date? = nil, description: String? = nil, location: String? = nil, registerLink: String? = nil, imageURL: String? = nil, sourceLink: String? = nil, type: String? = nil) {
        self.name = name
        self.date = date
        self.end = end 
        self.description = description
        self.location = location
        self.registerLink = URL(string: registerLink ?? "")
        self.imageURL = URL(string: imageURL ?? "")
        self.sourceLink = URL(string: sourceLink ?? "")
        self.type = type
    }
}
