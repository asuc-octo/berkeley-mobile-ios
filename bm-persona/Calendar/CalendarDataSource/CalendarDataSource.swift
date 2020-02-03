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
        print(dict)
        return CalendarEntry(name: "Testing name", campusLocation: "Somewhere", date: Date(), eventType: "L&S Advising")
    }
}
