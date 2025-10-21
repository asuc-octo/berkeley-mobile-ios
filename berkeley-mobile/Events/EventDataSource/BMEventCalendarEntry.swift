//
//  BMEventCalendarEntry.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class BMEventCalendarEntry: NSObject, NSCoding, Identifiable, BMCalendarEvent, HasImage, CanFavorite {
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
    var startDate: Date = Date()
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
        self.startDate = date
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
        coder.encode(startDate, forKey: ArgumentNames.date)
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
        self.startDate = date
        
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

extension BMEventCalendarEntry {
    
    static let sampleEntry = BMEventCalendarEntry(
        name: "Exhibit | A Storied Campus: Cal in Fiction",
        date: Date(),
        end: Date().addingTimeInterval(7200),
        descriptionText: "Mention of the name University of California, Berkeley, evokes a range of images: a celebrated institution, a seat of innovation, protests and activism, iconic architecture, colorful traditions, and … literary muse? The campus has long sparked the creativity of fiction writers, inspiring them to use it as a backdrop, a key player, or a barely disguised character within their tales. This exhibition highlights examples of these portrayals through book covers, excerpts, illustrations, photographs, and other materials largely selected from the University Archives and general collections of The Bancroft Library.",
        location: "The Rowell Exhibition Cases, Doe Library, 2nd floor",
        registerLink: "https://berkeley.edu/register",
        imageURL: "https://events.berkeley.edu/live/image/gid/139/width/200/height/200/crop/1/src_region/0,0,3200,2420/4595_cubanc00006587_ae_a.rev.1698182194.jpg",
        sourceLink: "https://berkeley.edu/event",
        type: "Default"
    )
}
