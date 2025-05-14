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
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch authStatus {
            case .notDetermined, .denied, .restricted:
            if #available(iOS 17.0, *) {
                try await eventStore.requestFullAccessToEvents()
            } else {
                try await eventStore.requestAccess(to: .event)
            }
            default:
                break
        }
        
        try saveEvent(calendarEvent, authStatus: authStatus)
    }
    
    private func saveEvent(_ calendarEvent: CalendarEvent, authStatus: EKAuthorizationStatus) throws {
        let eventStartDate = calendarEvent.date
        let eventEndDate = calendarEvent.end ?? calendarEvent.date
        
        let predicate = eventStore.predicateForEvents(withStart: eventStartDate, end: eventEndDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        let eventAlreadyExists = existingEvents.contains { $0.title == calendarEvent.name && $0.startDate == eventStartDate && $0.endDate == eventEndDate }
        
        guard !eventAlreadyExists else {
            throw BMError.eventAlreadyAddedInCalendar
        }
        
        let event: EKEvent = EKEvent(eventStore: eventStore)
        event.title = calendarEvent.name
        event.startDate = eventStartDate
        event.endDate = eventEndDate
        event.location = calendarEvent.location
        event.notes = calendarEvent.additionalDescription + (calendarEvent.descriptionText ?? "")
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            if #available(iOS 17.0, *) {
                if authStatus == .writeOnly {
                    throw BMError.mayExistedInCalendarAlready
                }
            }
        } catch {
            if let ekError = error as? EKError, ekError.errorCode == 1 {
                throw BMError.insufficientAccessToCalendar
            } else {
                throw error
            }
        }
    }
}
