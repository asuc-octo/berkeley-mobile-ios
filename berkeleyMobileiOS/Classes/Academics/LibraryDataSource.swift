//
//  LibraryDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate let kLibrariesEndpoint = kAPIURL + "/weekly_libraries"

class LibraryDataSource: ResourceDataSource {
    
    typealias ResourceType = Library
    
    // Fetch the list of libraries and report back to the completionHandler.
    static func fetchResources(_ completion: @escaping ([Resource]?) -> Void) 
    {
        Alamofire.request(kLibrariesEndpoint).responseJSON
        { response in
            
            if response.result.isFailure {
                print("[Error @ LibraryDataSource.fetchLibraries()]: request failed")
                return
            }
            
            let libraries = JSON(data: response.data!)["libraries"].map { (_, child) in parseLibrary(child) }
            completion(libraries)
        }
    }
    
    // Return a Library object parsed from JSON.
    private static func parseLibrary(_ json: JSON) -> Library
    {
        let formatter = sharedDateFormatter()
        let weeklyOpeningTimes  = json["weekly_opening_times"].map { (_, child) in formatter.date(from: child.string ?? "") }
        let weeklyClosingTimes  = json["weekly_closing_times"].map { (_, child) in formatter.date(from: child.string ?? "") }
        let weeklyByAppointment = json["weekly_by_appointment"].map { (_, child) in child.bool ?? false }
        
        let library = Library(name: json["name"].stringValue, campusLocation: json["campus_location"].string, phoneNumber: json["phone_number"].string, weeklyOpeningTimes: weeklyOpeningTimes, weeklyClosingTimes: weeklyClosingTimes, weeklyByAppointment: weeklyByAppointment, imageLink: json["image_link"].string, latitude: json["latitude"].double, longitude: json["longitude"].double)
        
        FavoriteStore.shared.restoreState(for: library)
        
        return library
    }
    
    private static func sharedDateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
    
}
