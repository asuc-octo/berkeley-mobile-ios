//
//  CampusCalendarDataSource.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCampusResourcesEndpoint = "Events"

class CampusCalendarDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()

    /// Returns the date for the given document name. Must match the format on Firebase.
    private static func dateForDocumentName(_ documentName: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: documentName)
    }
    
    /// Fetch the list of events and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    {
        let db = Firestore.firestore()
        db.collection(kCampusResourcesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let calendar = querySnapshot!.documents.map { (document) -> [CampusCalendarEntry] in
                    let dict = document.data()
                    return parseCalendarDay(document.documentID, dict: dict)
                }
                completion(Array(calendar.joined()))
            }
        }
    }

    /// Parses a Firestore document representing a single day and returns a list of `CalendarEntry` objects for the day.
    private static func parseCalendarDay(_ day: String, dict: [String: Any]) -> [CampusCalendarEntry] {
        guard let date = dateForDocumentName(day) else { return [] }
        let events = dict["Events"] as? [[String: Any]] ?? []
        return events.map { parseCalendarResource($0, date: date) }
    }
    
    /// Return a `CalendaryEntry` object parsed from a dictionary on the given `date`.
    private static func parseCalendarResource(_ dict: [String: Any], date: Date) -> CampusCalendarEntry {
        let entry = CampusCalendarEntry(name: dict["title"] as? String ?? "Unnamed",
                                  address: dict["location"] as? String,
                                  date: date,
                                  eventType: dict["category"] as? String ?? "Uncategorized")
        return entry
    }
}
