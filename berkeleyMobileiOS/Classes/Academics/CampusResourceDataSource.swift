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

fileprivate let kCampusResourcesEndpoint = kAPIURL + "/resources"

class CampusResourceDataSource: NSObject {
    typealias completionHandler = (_ halls: [CampusResource]?) -> Void
    
    // Fetch the list of campus resources and report back to the completionHandler.
    static func fetchCampusResources(_ completion: @escaping completionHandler)
    {
        Alamofire.request(kCampusResourcesEndpoint).responseJSON
            { response in
                if response.result.isFailure {
                    print("[Error @ CampusResourceDataSource.fetchCampusResources()]: request failed")
                    return
                }
                let campusResources = JSON(data: response.data!)["resources"].map { (_, child) in parseCampusResource(child) }
                completion(campusResources)
        }
    }
    
    // Return a CampusResource object parsed from JSON.
    private static func parseCampusResource(_ json: JSON) -> CampusResource
    {
        let campusResource = CampusResource(name: json["Resource"].stringValue, campusLocation: json["Office Location"].string, phoneNumber: json["Phone 1"].string, alternatePhoneNumber: json["Phone 2"].string, email: json["Email"].string, hours: json["Hours"].string, latitude: json["Latitude"].double, longitude: json["Longitude"].double, notes: json["Notes"].string)
        
        return campusResource
    }
}