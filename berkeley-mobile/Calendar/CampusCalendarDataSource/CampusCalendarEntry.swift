//
//  CalendarEntry.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

//
//  CampusCalendarEntry.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class CampusCalendarEntry: HasName {
    var eventType: String?
    // date from Firebase document name (used for upcoming events, filters, sorts, etc)
    let date: Date
    // date 'description' from Firebase entry (e.g. 'March 9 - May 1, 2020 every day') (used for detail view, user-facing)
    var dateString: String?
    var description: String?
    var imageURL: URL?
    var image: UIImage?
    var link: URL?
    var location: String?
    var status: String?
    var time: String?
    let name: String
    
    init(name: String, date: Date, dateString: String?, eventType: String?, description: String?, imageLink: String?,
         link: String?, location: String?, status: String?, time: String?) {
        self.name = name
        self.date = date
        self.dateString = dateString
        self.eventType = eventType
        self.description = description
        self.imageURL = URL(string: imageLink ?? "")
        self.link = URL(string: link ?? "")
        self.location = location
        self.status = status
        self.time = time
    }
    
}
