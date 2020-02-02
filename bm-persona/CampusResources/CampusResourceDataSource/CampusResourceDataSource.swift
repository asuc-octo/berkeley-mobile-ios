//
//  CampusResourceDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/25/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCampusResourcesEndpoint = "Resources"

class CampusResourceDataSource: DataSource {
    
    // Fetch the list of campus resources and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    {
        let db = Firestore.firestore()
        db.collection(kCampusResourcesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let campusResources = querySnapshot!.documents.map { (document) -> CampusResource in
                    let dict = document.data()
                    return parseCampusResource(dict)
                }
                completion(campusResources)
            }
        }
    }
    
    // Return a CampusResource object parsed from a dictionary.
    private static func parseCampusResource(_ dict: [String: Any]) -> CampusResource {
        let openClose = dict["open_close_array"] as? [[String: Any]]
        let weeklyHours = parseWeeklyTimes(openClose)
        let campusResource = CampusResource(name: dict["name"] as? String ?? "Unnamed",
                                            campusLocation: dict["address"] as? String,
                                            phoneNumber: dict["phone"] as? String,
                                            alternatePhoneNumber: nil,
                                            email: dict["email"] as? String,
                                            weeklyHours: openClose == nil ? nil : weeklyHours,
                                            byAppointment: dict["by_appointment"] as? Bool ?? false,
                                            latitude: dict["latitude"] as? Double,
                                            longitude: dict["longitude"] as? Double,
                                            notes: nil,
                                            imageLink: dict["picture"] as? String,
                                            description: dict["description"] as? String,
                                            category: nil)
        return campusResource
    }
}
