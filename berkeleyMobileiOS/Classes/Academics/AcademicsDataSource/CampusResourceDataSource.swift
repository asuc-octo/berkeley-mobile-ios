//
//  CampusResourceDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/25/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

fileprivate let kCampusResourcesEndpoint = "Resources"


class CampusResourceDataSource: ResourceDataSource 
{

    typealias ResourceType = CampusResource
    
    // Fetch the list of campus resources and report back to the completionHandler.
    static func fetchResources(_ completion: @escaping ([Resource]?) -> Void)
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
    
    static func parseResource(_ json: JSON) -> Resource {
        return parseCampusResource(json.dictionaryObject ?? [:])
    }
    
    // Return a CampusResource object parsed from a dictionary.
    private static func parseCampusResource(_ dict: [String: Any]) -> CampusResource {
        var byAppointment = false
        var weeklyHours = [DateInterval?](repeating: nil, count: 7)
        if let times = dict["open_close_array"] as? [[String: Any]] {
            weeklyHours = parseWeeklyTimes(times, openKey: "open_time", closeKey: "close_time")
        } else {
            byAppointment = true
        }
        let campusResource = CampusResource(name: dict["name"] as? String ?? "Unnamed",
                                            campusLocation: dict["address"] as? String,
                                            phoneNumber: dict["phone"] as? String,
                                            alternatePhoneNumber: nil,
                                            email: dict["email"] as? String,
                                            weeklyHours: weeklyHours,
                                            byAppointment: byAppointment,
                                            latitude: dict["latitude"] as? Double,
                                            longitude: dict["longitude"] as? Double,
                                            notes: nil,
                                            imageLink: dict["picture"] as? String,
                                            description: dict["description"] as? String,
                                            category: nil)
        return campusResource
    }
}
