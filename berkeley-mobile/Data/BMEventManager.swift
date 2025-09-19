//
//  BMEventManager.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/31/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import EventKit
import Foundation

class BMEventManager {
    static let shared = BMEventManager()
    
    private let eventStore = EKEventStore()
    
    func addEventToCalendar(calendarEvent: BMCalendarEvent) async throws {
        if #available(iOS 17.0, *) {
            try await eventStore.requestFullAccessToEvents()
        } else {
            try await eventStore.requestAccess(to: .event)
        }
        
        try saveEvent(calendarEvent)
    }
    
    func deleteEvent(_ calendarEvent: BMCalendarEvent) throws {
        let matchingExistingEvents = getMatchingEvents(for: calendarEvent)
        guard let eventToDelete = matchingExistingEvents.first(where: makeEventMatcher(for: calendarEvent)) else {
            throw BMError.unableToFindEventInCalendar
        }
        
        try eventStore.remove(eventToDelete, span: .thisEvent)
    }
    
    func doesEventExists(for calendarEvent: BMCalendarEvent) -> Bool {
        let matchingExistingEvents = getMatchingEvents(for: calendarEvent)
        let eventAlreadyExists = matchingExistingEvents.contains(where: makeEventMatcher(for: calendarEvent))
        return eventAlreadyExists
    }
    
    private func makeEventMatcher(for calendarEvent: BMCalendarEvent) -> (EKEvent) -> Bool {
        return { event in
            event.title == calendarEvent.name &&
            event.startDate == calendarEvent.startDate &&
            event.endDate == calendarEvent.endDate
        }
    }
    
    private func getMatchingEvents(for calendarEvent: BMCalendarEvent) -> [EKEvent] {
        guard let endDate = Calendar.current.date(byAdding: .year, value: 1, to: calendarEvent.startDate) else {
            return []
        }
        let predicate = eventStore.predicateForEvents(withStart: calendarEvent.startDate, end: endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        return existingEvents
    }
    
    private func saveEvent(_ calendarEvent: BMCalendarEvent) throws {
        let eventAlreadyExists = doesEventExists(for: calendarEvent)
        
        guard !eventAlreadyExists else {
            throw BMError.eventAlreadyAddedInCalendar
        }
        
        let event = getEKEventFromCalendarEvent(for: calendarEvent)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            if #available(iOS 17.0, *) {
                let authStatus = EKEventStore.authorizationStatus(for: .event)
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
    
    private func getEKEventFromCalendarEvent(for calendarEvent: BMCalendarEvent) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = calendarEvent.name
        event.startDate = calendarEvent.startDate
        event.endDate = calendarEvent.endDate
        event.location = calendarEvent.location
        event.notes = calendarEvent.additionalDescription + (calendarEvent.descriptionText ?? "")
        event.calendar = eventStore.defaultCalendarForNewEvents
        return event
    }
}
