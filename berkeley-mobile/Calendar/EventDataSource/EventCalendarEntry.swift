//
//  EventCalendarEntry.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

class EventCalendarEntry: NSObject, NSCoding, CalendarEvent, HasImage, CanFavorite {
    
    private struct ArgumentNames {
        static let name = "name"
        static let date = "date"
        static let end = "end"
        static let descriptionText = "descriptionText"
        static let location = "location"
        static let registerLink = "registerLink"
        static let imageURL = "imageURL"
        static let sourceLink = "sourceLink"
        static let type = "type"
    }
    
    // MARK: CalendarEvent Fields
    @Display var name: String = "N/A"
    var date: Date = Date()
    var end: Date?
    @Display var descriptionText: String?
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
    var type: String?

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

    init(name: String, date: Date, end: Date? = nil, descriptionText: String? = nil, location: String? = nil, registerLink: String? = nil, imageURL: String? = nil, sourceLink: String? = nil, type: String? = nil) {
        self.name = name
        self.date = date
        self.end = end 
        self.descriptionText = descriptionText
        self.location = location
        self.registerLink = URL(string: registerLink ?? "")
        self.imageURL = URL(string: imageURL ?? "")
        self.sourceLink = URL(string: sourceLink ?? "")
        self.type = type
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: ArgumentNames.name)
        coder.encode(date, forKey: ArgumentNames.date)
        coder.encode(end, forKey: ArgumentNames.end)
        coder.encode(descriptionText, forKey: ArgumentNames.descriptionText)
        coder.encode(location, forKey: ArgumentNames.location)
        coder.encode(registerLink, forKey: ArgumentNames.registerLink)
        coder.encode(imageURL, forKey: ArgumentNames.imageURL)
        coder.encode(sourceLink, forKey: ArgumentNames.sourceLink)
        coder.encode(type, forKey: ArgumentNames.type)
    }
    
    required init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: ArgumentNames.name) as? String,
              let date = coder.decodeObject(forKey: ArgumentNames.date) as? Date else {
            return nil
        }
        
        self.name = name
        self.date = date
        
        self.end = coder.decodeObject(forKey: ArgumentNames.end) as? Date
        self.descriptionText = coder.decodeObject(forKey: ArgumentNames.descriptionText) as? String
        self.location = coder.decodeObject(forKey: ArgumentNames.location) as? String
        
        if let registerLink = coder.decodeObject(forKey: ArgumentNames.registerLink) as? URL {
            self.registerLink = registerLink
        }
        
        if let imageURL = coder.decodeObject(forKey: ArgumentNames.imageURL) as? URL {
            self.imageURL = imageURL
        }
        
        if let sourceLink = coder.decodeObject(forKey: ArgumentNames.sourceLink) as? URL {
            self.sourceLink = sourceLink
        }
        
        self.type = coder.decodeObject(forKey: ArgumentNames.type) as? String
    }

    
}
