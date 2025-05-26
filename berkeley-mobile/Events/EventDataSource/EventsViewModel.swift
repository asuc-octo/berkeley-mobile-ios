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

    func showAddEventToCalendarAlert(_ event: BMEventCalendarEntry) {
        withoutAnimation {
            self.alert = BMAlert(title: "Add To Calendar", message: "Would you like to add this event to your calendar?", type: .action) {
                self.addAcademicEventToCalendar(event)
            }
        }
    }
    
    private func addAcademicEventToCalendar(_ event: BMEventCalendarEntry) {
        Task { @MainActor in
            do {
                try await BMEventManager.shared.addEventToCalendar(calendarEvent: event)
                withoutAnimation {
                    self.alert = BMAlert(title: "", message: "Successfully added to calendar!", type: .notice)
                }
            } catch {
                if let bmError = error as? BMError, bmError == .mayExistedInCalendarAlready {
                    withoutAnimation {
                        self.alert = BMAlert(title: "Successfully added to calendar!", message: error.localizedDescription, type: .notice)
                    }
                } else {
                    withoutAnimation {
                        self.alert = BMAlert(title: "Failed to add to calendar", message: error.localizedDescription, type: .notice)
                    }
                }
            }
        }
    }
}
