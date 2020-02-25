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

class ResourceDataSource: DataSource {
    
    // Fetch the list of campus resources and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    {
        let db = Firestore.firestore()
        db.collection(kCampusResourcesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let campusResources = querySnapshot!.documents.map { (document) -> ResourceEntry in
                    let dict = document.data()
                    return parseCampusResource(dict)
                }
                completion(campusResources)
            }
        }
    }
    
    // Return a CampusResource object parsed from a dictionary.
    private static func parseCampusResource(_ dict: [String: Any]) -> ResourceEntry {
        let openClose = dict["open_close_array"] as? [[String: Any]]
        let weeklyHours = parseWeeklyTimes(openClose)
        let campusResource = ResourceEntry(name: dict["name"] as? String ?? "Unnamed",
                                            campusLocation: dict["address"] as? String ?? "N/A",
                                            latitude: dict["latitude"] as? Double ?? 0.0,
                                            longitude: dict["longitude"] as? Double ?? 0.0,
                                            description: dict["description"] as? String ?? "")
        return campusResource
    }
}
