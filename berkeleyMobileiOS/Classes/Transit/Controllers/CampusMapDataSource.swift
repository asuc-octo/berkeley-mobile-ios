//
//  CampusMapDataSource.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 2/7/19.
//  Copyright © 2019 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Firebase

class CampusMapDataSource {
    static var queries = ["Libraries", "Mental Health Resources", "Microwaves", "Nap Pods", "Printers", "Water Fountains", "Ford Go Bikes"]
    
    static var queriesToLocations: [String: [Location]] = [:]
    
    static var completedFetchingLocations = false
    
    static func getLocations() {
        let db = Firestore.firestore()
        
        for query in queries {
            var locations: [Location] = []
            let formattedQuery = CampusMapModel.formatQuery(string: query)
            db.collection(query).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data: [String: Any] = document.data()
                        if let name = data["name"] as? String, let lat = data["latitude"] as? Double, let lon = data["longitude"] as? Double, let type = data["category"] as? String {
                            
                            let newLocation = Location(title: name, subtitle: type, coordinates: (lat, lon))
                            
                            if let moreInfo = data["description"] as? String {
                                newLocation.moreInfo = moreInfo
                                newLocation.numAttributes += 1
                            }
                            
                            if let notes = data["notes"] as? String {
                                newLocation.notes = notes
                                newLocation.numAttributes += 1
                            }
                            
                            if let openCloseArray = data["open_close_array"] as? [Any] {
                                newLocation.open_close_array = openCloseArray
                                newLocation.numAttributes += 1
                            }
                            
                            if let phoneNumber = data["phone"] as? String {
                                newLocation.phone = phoneNumber
                                newLocation.numAttributes += 1
                            }
                            
                            locations.append(newLocation)
                        }
                    }
                    queriesToLocations[formattedQuery] = locations
                    completedFetchingLocations = true
                }
                
            }
        }
        
    }
}

