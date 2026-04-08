//
//  EventsDataSource.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 7/6/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

/// Fetches events from the Firestore `Events V2` collection and exposes
/// them grouped by day, matching the interface previously used by the
/// web-scraping implementation.
class EventsDataSource: ObservableObject {
    enum EventCategory: Hashable {
        case academic
        case campuswide

        /// The Firestore `category` field value for this event type.
        var firestoreCategory: String {
            switch self {
            case .academic:
                return "Academic"
            case .campuswide:
                return "Campuswide"
            }
        }
    }

    @Published var groupedEntries: [Date: [BMEventCalendarEntry]] = [:]
    @Published var isLoading = false
    @Published var alert: BMAlert?

    var groupedEntriesSortedKeys: [Date] {
        groupedEntries.keys.sorted()
    }

    var allEntries: [BMEventCalendarEntry] {
        groupedEntries.flatMap { $0.1 }
    }

    let type: EventCategory

    private static let kEventsEndpoint = "Events V2"
    private let db = Firestore.firestore()

    init(type: EventCategory) {
        self.type = type
    }

    /// Fetches events from Firestore. The `forceRescrape` parameter is
    /// kept for API compatibility but has no special behavior — every
    /// call fetches fresh data from Firestore.
    func scrape(forceRescrape: Bool = false) {
        isLoading = true
        groupedEntries.removeAll()

        Task { @MainActor in
            defer { isLoading = false }

            do {
                let nowEpoch = Int(Date().timeIntervalSince1970)

                let snapshot = try await db.collection(Self.kEventsEndpoint)
                    .whereField("category", isEqualTo: type.firestoreCategory)
                    .whereField("date", isGreaterThanOrEqualTo: nowEpoch)
                    .order(by: "date")
                    .limit(to: 200)
                    .getDocuments()

                let entries: [BMEventCalendarEntry] = snapshot.documents.compactMap { doc in
                    Self.mapDocumentToEntry(doc.data())
                }

                groupedEntries = Dictionary(grouping: entries) { $0.startDate.getStartOfDay() }
            } catch {
                alert = BMAlert(
                    title: "Unable To Load Events",
                    message: error.localizedDescription,
                    type: .notice
                )
            }
        }
    }

    // MARK: - Firestore → BMEventCalendarEntry Mapping

    private static func mapDocumentToEntry(_ data: [String: Any]) -> BMEventCalendarEntry? {
        guard let name = data["name"] as? String,
              let dateEpoch = data["date"] as? Int else {
            return nil
        }

        let startDate = Date(timeIntervalSince1970: TimeInterval(dateEpoch))

        var endDate: Date? = nil
        if let misc = data["miscellaneous"] as? [String: Any],
           let endEpoch = misc["end_date"] as? Int {
            endDate = Date(timeIntervalSince1970: TimeInterval(endEpoch))
        }

        let description = data["description"] as? String
        let location = data["location"] as? String
        let picture = data["picture"] as? String
        let eventLink = data["event_link"] as? String
        let type = data["type"] as? String

        return BMEventCalendarEntry(
            name: name,
            date: startDate,
            end: endDate,
            descriptionText: description,
            location: location,
            imageURL: picture,
            sourceLink: eventLink,
            type: (type?.isEmpty ?? true) ? nil : type
        )
    }
}
