//
//  LibraryDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Firebase

fileprivate let kLibrariesEndpoint = "Libraries"

class LibraryDataSource: DataSource {
    
    static var fetchDispatch: DispatchGroup = DispatchGroup()
    
    typealias ResourceType = Library
    
    // Fetch the list of libraries and report back to the completionHandler.
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
    {
        let db = Firestore.firestore()
        db.collection(kLibrariesEndpoint).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                let libraries = querySnapshot!.documents.map { (document) -> Library in
                    let dict = document.data()
                    return parseLibrary(dict)
                }
                completion(libraries)
            }
        }
    }
    
    // Return a Library object parsed from a dictionary.
    private static func parseLibrary(_ dict: [String: Any]) -> Library {
        let weeklyHours = Library.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        let library = Library(name: dict["name"] as? String ?? "Unnamed",
                              campusLocation: dict["address"] as? String,
                              phoneNumber: dict["phone"] as? String,
                              weeklyHours: weeklyHours,
                              weeklyByAppointment: [],
                              imageLink: dict["picture"] as? String,
                              latitude: dict["latitude"] as? Double,
                              longitude: dict["longitude"] as? Double)
        
        return library
    }
    
}
