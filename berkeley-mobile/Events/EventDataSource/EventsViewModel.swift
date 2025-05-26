//
//  EventsViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FirebaseAnalytics
import SwiftUI

class EventsViewModel: ObservableObject {
    @Published var alert: BMAlert?
    
    func logAcademicCalendarTabAnalytics() {
        Analytics.logEvent("opened_academic_calendar", parameters: nil)
    }
    
    func logCampuswideTabAnalytics() {
        Analytics.logEvent("opened_campus_wide_events", parameters: nil)
    }

    func showAddEventToCalendarAlert(_ event: EventCalendarEntry) {
        alert = BMAlert(title: "Add To Calendar", message: "Would you like to add this event to your calendar?", type: .action) {
            self.addAcademicEventToCalendar(event)
        }
    }
    
    func doesEventExist(for event: EventCalendarEntry) -> Bool {
        BMEventManager.shared.doesEventExists(for: event)
    }
    
    func deleteEvent(for event: EventCalendarEntry) {
        do {
            try BMEventManager.shared.deleteEvent(event)
            alert = BMAlert(title: "Successfully Deleted", message: "Event has been successfully deleted from your Calendar.", type: .notice)
        } catch {
            alert = BMAlert(title: "Unable To Delete Event", message: error.localizedDescription, type: .notice)
        }
    }
    
    private func addAcademicEventToCalendar(_ event: EventCalendarEntry) {
        Task { @MainActor in
            do {
                try await BMEventManager.shared.addEventToCalendar(calendarEvent: event)
                alert = BMAlert(title: "", message: "Successfully added to calendar!", type: .notice)
            } catch {
                if let bmError = error as? BMError, bmError == .mayExistedInCalendarAlready {
                    alert = BMAlert(title: "Successfully added to calendar!", message: error.localizedDescription, type: .notice)
                } else {
                    alert = BMAlert(title: "Failed to add to calendar", message: error.localizedDescription, type: .notice)
                }
            }
        }
    }
}
