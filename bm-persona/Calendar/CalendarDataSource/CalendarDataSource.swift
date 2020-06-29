//
//  CalendarDataSource.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCampusResourcesEndpoint = "Academic Calendar Events"

class CalendarDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the list of campus resources and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    {
        let db = Firestore.firestore()
        db.collection(kCampusResourcesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let calendar = querySnapshot!.documents.map { (document) -> CalendarEntry in
                    let dict = document.data()
                    return parseCalendarResource(dict)
                }
                completion(calendar)
            }
        }
    }
    
    // Return a CalendaryEntry object parsed from a dictionary.
    private static func parseCalendarResource(_ dict: [String: Any]) -> CalendarEntry {
        var date = Date(timeIntervalSince1970: dict["event_date"] as? Double ?? 0)
        
#if DEBUG
        date = Calendar.current.date(byAdding: .year, value: 1, to: date)!
#endif
        
        let entry = CalendarEntry(name: dict["event_name"] as? String ?? "Unnamed",
                                  campusLocation: "TBD",
                                  date: date,
                                  eventType: dict["event_type"] as? String ?? "Uncategorized")
        return entry
    }
}
