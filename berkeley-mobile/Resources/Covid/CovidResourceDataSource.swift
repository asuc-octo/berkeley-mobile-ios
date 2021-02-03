//
//  CovidDataSource.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 11/21/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kCovidResourcesEndpoint = "Covid Data"

class CovidResourceDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    // Fetch the covid data and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    {
        let db = Firestore.firestore()
        db.collection(kCovidResourcesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let covidResources = querySnapshot!.documents.map { (document) -> CovidResource in
                    let dict = document.data()
                    return parseCovidResource(dict)
                }
                completion(covidResources)
            }
        }
    }
    
    private static func parseCovidResource(_ dict: [String: Any]) -> CovidResource {
        return CovidResource(
            dailyScreeningLink: dict["daily_screen_link"] as? String ?? "",
            lastUpdated: dict["last_updated"] as? Double ?? 0.0,
            positivityRate: dict["positivity_rate"] as? String ?? "",
            totalCases: dict["total_cases"] as? String ?? "",
            dailyIncrease: dict["daily_increase"] as? String ?? "")
    }
    
}
