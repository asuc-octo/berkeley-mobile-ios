//
//  EventManager.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/31/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import EventKit

class EventManager: NSObject {
    static let shared = EventManager()
    private let eventStore = EKEventStore()
    
    public func addEventToCalendar(calendarEvent: CalendarEvent) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                let event: EKEvent = EKEvent(eventStore: self.eventStore)
                event.title = calendarEvent.name
                event.startDate = calendarEvent.date
                event.endDate = calendarEvent.end ?? calendarEvent.date
                event.location = calendarEvent.location
                event.notes = calendarEvent.additionalDescription + (calendarEvent.description ?? "")
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
            } else {
                print("failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
    }
}
