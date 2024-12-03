//
//  CalendarEvent.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 9/22/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

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
    var descriptionText: String? { get set }
    
    /// Subclass specific additional description to include when adding the event to the user's calendar. Should be used to include details like gym class trainer, links, etc.
    var additionalDescription: String { get }
    
    /// A string describing where the event will be held.
    var location: String? { get set }
}

extension CalendarEvent {
    /// Prompts and adds this event to the user's local calendar.
    ///
    /// Override this function if additional fields need to be included in the exported event.
    public func addToDeviceCalendar(vc: UIViewController) {
        let alertController = AlertView(headingText: "Add to Calendar", messageText: "Would you like to add this event to your calendar?", action1Label: "Cancel", action1Color: BMColor.AlertView.secondaryButton, action1Completion: {
            vc.dismiss(animated: true, completion: nil)
        }, action2Label: "Yes", action2Color: BMColor.ActionButton.background, action2Completion: {
            EventManager.shared.addEventToCalendar(calendarEvent: self) { success in
                DispatchQueue.main.async {
                    if success {
                        vc.dismiss(animated: true, completion: nil)
                        vc.presentSuccessAlert(title: "Successfully added to calendar")
                    } else {
                        vc.dismiss(animated: true, completion: nil)
                        vc.presentFailureAlert(title: "Failed to add to calendar", message: "Make sure Berkeley Mobile has access to your calendar and try again.")
                    }
                }
            }
        }, withOnlyOneAction: false)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    var dateString: String {
        get {
            var dateString = ""
            
            if date.dateOnly() == Date().dateOnly() {
                dateString += "Today"
            } else if Date.isDateTomorrow(baseDate: Date(), date: date) {
                dateString += "Tomorrow"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateString += dateFormatter.string(from: date)
            }
            dateString += " / "
            
            // Check if to see if event is an "All Day" event
            if date.doesDateComponentsAreEqualTo(hour: 0, minute: 0, sec: 0), let end,
                end.doesDateComponentsAreEqualTo(hour: 11, minute: 59, sec: 59) {
                return dateString + "All Day"
            }
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            
            dateString += date.getDateString(withFormatter: timeFormatter)
            
            if let end {
                dateString += " - \(end.getDateString(withFormatter: timeFormatter))"
            }
            
            return dateString
        }
    }
}
