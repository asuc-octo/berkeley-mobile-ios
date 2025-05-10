//
//  EventManager.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/31/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import EventKit
import Foundation

class EventManager {
    static let shared = EventManager()
    
    private let eventStore = EKEventStore()
    
    public func addEventToCalendar(calendarEvent: CalendarEvent) async throws {
        var success = false
        
        if #available(iOS 17.0, *) {
            success = try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            success = try await eventStore.requestAccess(to: .event)
        }
        
        try saveEvent(calendarEvent, shouldSave: success)
    }
    
    private func saveEvent(_ calendarEvent: CalendarEvent, shouldSave: Bool) throws {
        let event: EKEvent = EKEvent(eventStore: eventStore)
        event.title = calendarEvent.name
        event.startDate = calendarEvent.date
        event.endDate = calendarEvent.end ?? calendarEvent.date
        event.location = calendarEvent.location
        event.notes = calendarEvent.additionalDescription + (calendarEvent.descriptionText ?? "")
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(event, span: .thisEvent)
    }
}
