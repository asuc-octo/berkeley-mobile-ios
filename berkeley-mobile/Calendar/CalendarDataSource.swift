//
//  CalendarDataSource.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCampusResourcesEndpoint = "Events"

class CalendarDataSource: DataSource {
    
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
                let calendar = querySnapshot!.documents.map { (document) -> [CalendarEntry] in
                    let dict = document.data()
                    return parseCalendarDay(document.documentID, dict: dict)
                }
                completion(Array(calendar.joined()))
            }
        }
    }

    /// Parses a Firestore document representing a single day and returns a list of `CalendarEntry` objects for the day.
    private static func parseCalendarDay(_ day: String, dict: [String: Any]) -> [CalendarEntry] {
        guard let date = dateForDocumentName(day) else { return [] }
        let events = dict["Events"] as? [[String: Any]] ?? []
        return events.map { parseCalendarResource($0, date: date) }
    }
    
    /// Return a `CalendaryEntry` object parsed from a dictionary on the given `date`.
    private static func parseCalendarResource(_ dict: [String: Any], date: Date) -> CalendarEntry {
        let entry = CalendarEntry(name: dict["title"] as? String ?? "Unnamed",
                                  date: date,
                                  dateString: dict["date"] as? String,
                                  eventType: dict["category"] as? String,
                                  description: dict["description"] as? String,
                                  imageLink: dict["image"] as? String,
                                  link: dict["link"] as? String,
                                  location: dict["location"] as? String,
                                  status: dict["status"] as? String,
                                  time: dict["time"] as? String)
        
        return entry
    }
}
