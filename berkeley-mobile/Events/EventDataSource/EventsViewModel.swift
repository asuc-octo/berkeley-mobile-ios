//
//  EventsViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FirebaseAnalytics
import SwiftUI

@MainActor
class EventsViewModel: ObservableObject {
    @Published var alert: BMAlert?
    
    private(set) var didCacheEventsExistence = Set<EventScrapper.EventScrapperType>()
    private let eventManager = BMEventManager()
    
    func logAcademicCalendarTabAnalytics() {
        Analytics.logEvent("opened_academic_calendar", parameters: nil)
    }
    
    func logCampuswideTabAnalytics() {
        Analytics.logEvent("opened_campus_wide_events", parameters: nil)
    }
    
    func showAddEventToCalendarAlert(_ event: BMEventCalendarEntry) {
        presentAlertWithoutAnimation(BMAlert(title: "Add To Calendar", message: "Would you like to add this event to your calendar?", type: .action) {
            self.addAcademicEventToCalendar(event)
        })
    }
    
    func showDeleteEventFromCalendarAlert(_ event: BMEventCalendarEntry) {
        presentAlertWithoutAnimation(BMAlert(title: "Delete Event?", message: "Do you want to delete this event from your Calendar?", type: .action) {
            Task {
                await self.deleteEvent(for: event)
            }
        })
    }
    
    func cacheEventsExistence(for events: [BMEventCalendarEntry], scrapperType: EventScrapper.EventScrapperType) async {
        await eventManager.processEventsExistenceInCalendar(for: events)
        didCacheEventsExistence.insert(scrapperType)
    }
    
    func doesEventExists(for event: BMEventCalendarEntry) -> Bool {
        return eventManager.doesEventsExistInCalendarDict[event.uniqueIdentifier] ?? false
    }
    
    func deleteEvent(for event: BMEventCalendarEntry) async {
        do {
            try await eventManager.deleteEvent(event)
            presentAlertWithoutAnimation(BMAlert(title: "Successfully Deleted", message: "Event has been successfully deleted from your Calendar.", type: .notice))
        } catch {
            presentAlertWithoutAnimation(BMAlert(title: "Unable To Delete Event", message: error.localizedDescription, type: .notice))
        }
    }
    
    func addAcademicEventToCalendar(_ event: BMEventCalendarEntry) {
        Task { @MainActor in
            do {
                try await eventManager.addEventToCalendar(calendarEvent: event)
                presentAlertWithoutAnimation(BMAlert(title: "Event Added To Calendar", message: "Would you like to open this event in Calendar?", type: .action) {
                    let interval = event.startDate.timeIntervalSinceReferenceDate
                    let url = URL(string: "calshow:\(interval)")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
            } catch {
                if let bmError = error as? BMError, bmError == .mayExistedInCalendarAlready {
                    presentAlertWithoutAnimation(BMAlert(title: "Successfully added to calendar!", message: error.localizedDescription, type: .notice))
                } else {
                    presentAlertWithoutAnimation(BMAlert(title: "Failed to add to calendar", message: error.localizedDescription, type: .notice))
                }
            }
        }
    }
    
    private func presentAlertWithoutAnimation(_ alert: BMAlert) {
        withoutAnimation {
            self.alert = alert
        }
    }
}
