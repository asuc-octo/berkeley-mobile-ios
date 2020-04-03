//
//  CampusResourceDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/25/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCampusResourcesEndpoint = "Campus Resource"

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
                let campusResources = querySnapshot!.documents.map { (document) -> Resource in
                    let dict = document.data()
                    return parseCampusResource(dict)
                }
                completion(campusResources)
            }
        }
    }
    
    // Return a CampusResource object parsed from a dictionary.
    private static func parseCampusResource(_ dict: [String: Any]) -> Resource {
        let weeklyHours = Resource.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        let campusResource = Resource(name: dict["name"] as? String ?? "Unnamed",
                                            campusLocation: dict["address"] as? String,
                                            latitude: dict["latitude"] as? Double,
                                            longitude: dict["longitude"] as? Double,
                                            description: dict["description"] as? String,
                                            hours: weeklyHours)
        return campusResource
    }
}
