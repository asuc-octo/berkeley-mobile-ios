//
//  EventDataSource.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kEventsEndpoint = "Events"

class EventDataSource: DataSource {

    static var fetchDispatch: DispatchGroup = DispatchGroup()

    // Fetch the list of Academic Calendar Events and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let db = Firestore.firestore()
        db.collection(kEventsEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let calendar = querySnapshot!.documents.compactMap { (document) -> EventCalendarEntry? in
                    let dict = document.data()
                    let entry = parseCalendarEntry(dict)
                    return entry
                }
                completion(calendar)
            }
        }
    }

    /// Return an `AcademicCalendaryEntry` object parsed from a dictionary. Returns `nil` if the required fields cannot be properly parsed.
    private static func parseCalendarEntry(_ dict: [String: Any]) -> EventCalendarEntry? {
        guard let dateValue = dict["date"] as? Double else { return nil }
        return EventCalendarEntry(
            category: dict["category"] as? String ?? "Uncategorized",
            name: dict["name"] as? String ?? "Unnamed",
            date: Date(timeIntervalSince1970: dateValue),
            description: dict["description"] as? String,
            location: dict["location"] as? String,
            link: dict["event_link"] as? String,
            imageURL: dict["picture"] as? String,
            sourceLink: dict["source_link"] as? String,
            type: dict["type"] as? String
        )
    }
}
