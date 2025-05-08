//
//  AcademicCalendarViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FirebaseAnalytics
import SwiftUI

class AcademicCalendarViewModel: ObservableObject {
    @Published var calendarEntries: [EventCalendarEntry] = []
    @Published var isLoading = false
    @Published var alert: BMAlert?
    
    private let eventScrapper = EventScrapper()
    
    init() {
        eventScrapper.delegate = self
    }
    
    func scrapeAcademicEvents() {
        isLoading = true
        let academicCalendarURLString = EventScrapper.Constants.academicCalendarURLString
        let rescapeData = eventScrapper.shouldRescrape(for: academicCalendarURLString, lastRefreshDateKey: UserDefaultsKeys.academicEventsLastSavedDate.rawValue)
        
        if rescapeData.shouldRescape {
            eventScrapper.scrape(at: academicCalendarURLString)
        } else {
            calendarEntries = rescapeData.savedEvents
            isLoading = false
        }
    }
    
    func logAcademicCalendarTabAnalytics() {
        Analytics.logEvent("opened_academic_calendar", parameters: nil)
    }
    
    func showAddEventToCalendarAlert(_ event: EventCalendarEntry) {
        withoutAnimation {
            self.alert = BMAlert(title: "Add To Calendar", message: "Would you like to add this event to your calendar?", type: .action) {
                self.addAcademicEventToCalendar(event)
            }
        }
    }
    
    private func addAcademicEventToCalendar(_ event: EventCalendarEntry) {
        EventManager.shared.addEventToCalendar(calendarEvent: event) { success in
            DispatchQueue.main.async {
                withoutAnimation {
                    if success {
                        self.alert = BMAlert(title: "", message: "Successfully added to calendar!", type: .notice)
                    } else {
                        self.alert = BMAlert(title: "Failed to add to calendar", message: "Make sure Berkeley Mobile has access to your calendar and try again.", type: .notice)
                    }
                }
            }
        }
    }
}


// MARK: - EventScrapperDelegate

extension AcademicCalendarViewModel: EventScrapperDelegate {
    func eventScrapperDidFinishScrapping(results: [EventCalendarEntry]) {
        isLoading = false
        calendarEntries = results
    }
    
    func eventScrapperDidError(with errorDescription: String) {
        isLoading = false
        withoutAnimation {
            self.alert = BMAlert(title: "", message: "Successfully added to calendar!", type: .notice)
        }
    }
}
