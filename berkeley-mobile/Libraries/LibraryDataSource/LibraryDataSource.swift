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
        #if DEBUG
        var weeklyHours: WeeklyHours?
        if let name = dict["name"] as? String, name < "I" {
            weeklyHours = Library.parseWeeklyHours(dict: LibraryDataSource.testOpenTimes0)
        } else if let name = dict["name"] as? String, name < "M" {
            weeklyHours = Library.parseWeeklyHours(dict: LibraryDataSource.testOpenTimes1)
        } else {
            weeklyHours = Library.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        }
        #else
        let weeklyHours = Library.parseWeeklyHours(dict: dict["open_close_array"] as? [[String: Any]])
        #endif
        let library = Library(name: dict["name"] as? String ?? "Unnamed",
                              address: dict["address"] as? String,
                              phoneNumber: dict["phone"] as? String,
                              weeklyHours: weeklyHours,
                              weeklyByAppointment: [],
                              imageLink: dict["picture"] as? String,
                              latitude: dict["latitude"] as? Double,
                              longitude: dict["longitude"] as? Double)
        
        return library
    }
    
    // libraries are all closed so we're using some random cafe/dining hall open times data to simulate
    static let testOpenTimes0: [[String: Double]] =
    [[
        "close_time": 1593392400,
        "open_time": 1593365400,
    ],
    [
        "close_time": 1593482400,
        "open_time": 1593439200,
    ],
    [
        "close_time": 1593568800,
        "open_time": 1593525600,
    ],
    [
        "close_time": 1593655200,
        "open_time": 1593612000,
    ],
    [
        "close_time": 1593741600,
        "open_time": 1593698400,
    ],
    [
        "close_time": 1593759600,
        "open_time": 1593759600,
    ],
    [
        "close_time": 1593903600,
        "open_time": 1593876600,
    ]]
    
    static let testOpenTimes1: [[String: Double]] =
    [[
        "close_time": 1584462600,
        "open_time": 1584453600,
    ],
    [
        "close_time": 1584549000,
        "open_time": 1584540000,
    ],
    [
        "close_time": 1584635400,
        "open_time": 1584626400,
    ],
    [
        "close_time": 1584721800,
        "open_time": 1584712800,
    ],
    [
        "close_time": 1584808200,
        "open_time": 1584799200,
    ],
    [
        "close_time": 1584394200,
        "open_time": 1584378000,
    ],
    [
        "close_time": 1584415800,
        "open_time": 1584403200,
    ],
    [
        "close_time": 1584502200,
        "open_time": 1584489600,
    ],
    [
        "close_time": 1584588600,
        "open_time": 1584576000,
    ],
    [
        "close_time": 1584675000,
        "open_time": 1584662400,
    ],
    [
        "close_time": 1584761400,
        "open_time": 1584748800,
    ],
    [
        "close_time": 1584847800,
        "open_time": 1584835200,
    ]]
}
