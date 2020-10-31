//
//  CalendarEvent.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 9/22/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation

/// Items conforming to this protocol are events that can be represented on a calendar.
protocol CalendarEvent {

    /// The name of the event.
    var name: String { get set }

    /// The date and time that the event starts.
    var date: Date { get set }
    
    /// Formatted date string to display. Shows "Date / Time" or "Today / Time".
    var dateString: String { get }

    /// The end date for the event. This value can be `nil` (e.g. for a deadline or reminder).
    var end: Date? { get set }

    /// An optional description for the event.
    var description: String? { get set }

    /// A string describing where the event will be held.
    ///
    /// When the value of this variable is a URL, this is an online event.
    var location: String? { get set }
}

extension CalendarEvent {
    /// Prompts and adds this event to the user's local calendar.
    ///
    /// Override this function if additional fields need to be included in the exported event.
    public func addToDeviceCalendar() {
        // TODO: https://www.notion.so/Sprint-Board-iOS-3a44a1f5f7044adab2ea4b7827e7ea5c?p=a47d9fb0b7174b919afde6f52df0f3c7
    }
    
    var dateString: String {
        get {
            var dateString = ""
            if date.dateOnly() == Date().dateOnly() {
                dateString += "Today / "
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateString += dateFormatter.string(from: date) + " / "
            }
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            dateString += timeFormatter.string(from: date)
            return dateString
        }
    }
}
