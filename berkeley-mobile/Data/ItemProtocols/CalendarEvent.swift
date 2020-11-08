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
    var description: String? { get set }
    
    /// Subclass specific additional description to include when adding the event to the user's calendar. Should be used to include details like gym class trainer, links, etc.
    var additionalDescription: String { get }
    
    /// A string describing where the event will be held.
    ///
    /// When the value of this variable is a URL, this is an online event.
    var location: String? { get set }
}

extension CalendarEvent {
    /// Prompts and adds this event to the user's local calendar.
    ///
    /// Override this function if additional fields need to be included in the exported event.
    public func addToDeviceCalendar(vc: UIViewController) {
        let alertController = UIAlertController(title: "Add to Calendar", message: "Would you like to add this event to your calendar?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { _ in
            EventManager.shared.addEventToCalendar(calendarEvent: self) { success in
                DispatchQueue.main.async {
                    if success {
                        vc.presentSuccessAlert(title: "Successfully added to Calendar")
                    } else {
                        vc.presentFailureAlert(title: "Failed to Add to Calendar", message: "Make sure Berkeley Mobile has access to your Calendar and try again.")
                    }
                }
            }
        }))
        vc.present(alertController, animated: true, completion: nil)
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
