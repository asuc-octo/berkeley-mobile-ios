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
    
    private let eventStore = EKEventStore()
    private let queue = DispatchQueue(label: "com.berkeleymobile.eventstore", qos: .userInitiated)
    
    /// A dictionary to keep track if events exist in Calendar. Keys are `BMEventCalendarEntry`'s `uniqueIdentifier`.
    private(set) var doesEventsExistInCalendarDict: [String: Bool] = [:]

    func addEventToCalendar(calendarEvent: BMCalendarEvent) async throws {
        try await eventStore.requestAccess(to: .event)
        
        try await saveEvent(calendarEvent)
        
        if let event = calendarEvent as? BMEventCalendarEntry {
            doesEventsExistInCalendarDict[event.uniqueIdentifier] = true
        }
    }
    
    func deleteEvent(_ calendarEvent: BMCalendarEvent) async throws {
        let matchingExistingEvents = await getMatchingEvents(for: calendarEvent)
        guard let eventToDelete = matchingExistingEvents.first(where: makeEventMatcher(for: calendarEvent)) else {
            throw BMError.unableToFindEventInCalendar
        }
        
        try eventStore.remove(eventToDelete, span: .thisEvent)
        
        if let event = calendarEvent as? BMEventCalendarEntry {
            doesEventsExistInCalendarDict.removeValue(forKey: event.uniqueIdentifier)
        }
    }
    
    func doesEventExists(for calendarEvent: BMCalendarEvent) async -> Bool {
        let matchingExistingEvents = await getMatchingEvents(for: calendarEvent)
        let eventAlreadyExists = matchingExistingEvents.contains(where: makeEventMatcher(for: calendarEvent))
        return eventAlreadyExists
    }
    
    func processEventsExistenceInCalendar(for events: [BMEventCalendarEntry]) async {
        let results: [(BMEventCalendarEntry, Bool)] = await withTaskGroup(of: (BMEventCalendarEntry, Bool).self) { group in
            for event in events {
                group.addTask {
                    let exists = await self.doesEventExists(for: event)
                    return (event, exists)
                }
            }
            var acc: [(BMEventCalendarEntry, Bool)] = []
            for await pair in group { acc.append(pair) }
            return acc
        }
        
        for (event, exists) in results {
            doesEventsExistInCalendarDict[event.uniqueIdentifier] = exists
        }
    }
    
    
    // MARK: - Private Methods
    
    private func makeEventMatcher(for calendarEvent: BMCalendarEvent) -> (EKEvent) -> Bool {
        return { event in
            event.title == calendarEvent.name &&
            event.startDate == calendarEvent.startDate &&
            event.endDate == calendarEvent.endDate
        }
    }
    
    private func getMatchingEvents(for calendarEvent: BMCalendarEvent) async -> [EKEvent] {
        await withCheckedContinuation { continuation in
            _getMatchingEvents(for: calendarEvent) { continuation.resume(returning: $0) }
        }
    }
    
    private func _getMatchingEvents(for calendarEvent: BMCalendarEvent, completion: @escaping ([EKEvent]) -> Void) {
        guard let endDate = Calendar.current.date(byAdding: .year, value: 1, to: calendarEvent.startDate) else {
            completion([])
            return
        }
        
        queue.async { [eventStore] in
            let predicate = eventStore.predicateForEvents(withStart: calendarEvent.startDate, end: endDate, calendars: nil)
            let matchingEvents = eventStore.events(matching: predicate)
            
            completion(matchingEvents)
        }
    }
    
    private func saveEvent(_ calendarEvent: BMCalendarEvent) async throws {
        let eventAlreadyExists = await doesEventExists(for: calendarEvent)
        
        guard !eventAlreadyExists else {
            throw BMError.eventAlreadyAddedInCalendar
        }
        
        let event = getEKEventFromCalendarEvent(for: calendarEvent)
        
        do {
            try eventStore.save(event, span: .thisEvent)

            let authStatus = EKEventStore.authorizationStatus(for: .event)
            if authStatus == .writeOnly {
                throw BMError.mayExistedInCalendarAlready
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
