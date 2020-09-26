//
//  AcademicCalendarDataSource.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCampusResourcesEndpoint = "Academic Calendar Events"

class AcademicCalendarDataSource: DataSource {

    static var fetchDispatch: DispatchGroup = DispatchGroup()

    // Fetch the list of Academic Calendar Events and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler) {
        let db = Firestore.firestore()
        db.collection(kCampusResourcesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let calendar = querySnapshot!.documents.compactMap { (document) -> AcademicCalendarEntry? in
                    let dict = document.data()
                    return parseCalendarEntry(dict)
                }
                completion(calendar)
            }
        }
    }

    /// Return an `AcademicCalendaryEntry` object parsed from a dictionary. Returns `nil` if the required fields cannot be properly parsed.
    private static func parseCalendarEntry(_ dict: [String: Any]) -> AcademicCalendarEntry? {
        guard let dateValue = dict["event_date"] as? Double else { return nil }
        return AcademicCalendarEntry(
            name: dict["event_name"] as? String ?? "Unnamed",
            date: Date(timeIntervalSince1970: dateValue),
            description: dict["event_description"] as? String,
            location: dict["event_link"] as? String,
            type: dict["event_type"] as? String
        )
    }
}
