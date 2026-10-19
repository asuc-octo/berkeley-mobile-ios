//
//  EventsViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import FirebaseAnalytics
import SwiftUI
import os

fileprivate let kEventsDataServiceEndpoint = "Events"

struct BerkeleyEventsDaySnapshot: Codable {
    var date: Date?
    var displayDate: String?
    var scrapedAt: Date?
    var events: [BerkeleyEvent]
}

struct BerkeleyEvent: Codable {
    let startTime: Date?
    let endTime: Date?
    let eventName: String?
    let eventDescription: String?
    let eventRegisterLinkURL: URL?
    let eventImageURL: URL?
    let eventURL: URL?
    let isAllDay: Bool?
    let location: String?
}

class EventsDataService {
    static var shared = EventsDataService()

    private let db = Firestore.firestore()

    func fetchEventsGroupedByDate() async -> [(Date, [BMEventCalendarEntry])] {
        guard let snap = try? await db.collection(kEventsDataServiceEndpoint).getDocuments() else {
            return []
        }

        var daySnapshots: [BerkeleyEventsDaySnapshot] = []
        for doc in snap.documents {
            do {
                daySnapshots.append(try doc.data(as: BerkeleyEventsDaySnapshot.self))
            } catch {
                Logger.eventsDataService.error("Cannot decode BerkeleyEventsDaySnapshot: \(error.localizedDescription)")
            }
        }

        var eventsPerDay: [(Date, [BMEventCalendarEntry])] = []

        for daySnapshot in daySnapshots {
            guard let date = daySnapshot.date else { continue }
            let dayEvents = daySnapshot.events.map {
                BMEventCalendarEntry(name: $0.eventName ?? "",
                                     date: $0.startTime ?? Date().getStartOfDay(),
                                     end: $0.endTime,
                                     descriptionText: $0.eventDescription,
                                     location: $0.location,
                                     registerLink: $0.eventRegisterLinkURL?.absoluteString,
                                     imageURL: $0.eventImageURL?.absoluteString,
                                     sourceLink: $0.eventURL?.absoluteString,
                                     isAllDay: $0.isAllDay)
            }
            eventsPerDay.append((date, dayEvents))
        }

        return eventsPerDay
    }
}

@MainActor
@Observable
class EventsViewModel {
    var eventsGroupedByDate: [(Date, [BMEventCalendarEntry])] = []
    var isProcessingEventsExistence = false
    var alert: BMAlert?

    private let eventManager = BMEventManager()

    init() {
        Task {
            isProcessingEventsExistence = true
            eventsGroupedByDate = await EventsDataService.shared.fetchEventsGroupedByDate()
            await cacheEventsExistence(for: eventsGroupedByDate.flatMap { $0.1 } )
            isProcessingEventsExistence = false
        }
    }

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
    
    func cacheEventsExistence(for events: [BMEventCalendarEntry]) async {
        await eventManager.processEventsExistenceInCalendar(for: events)
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
