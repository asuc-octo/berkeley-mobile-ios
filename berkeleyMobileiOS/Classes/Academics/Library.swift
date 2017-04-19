//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class Library: Resource {
    
    static func displayName(pluralized: Bool) -> String {
        return "Librar" + (pluralized ? "ies" : "y")
    }
    
    static var dataSource: ResourceDataSource.Type? = LibraryDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = LibraryDetailViewController.self
    
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    let campusLocation: String?
    let phoneNumber: String?
    var weeklyOpeningTimes:[Date?]
    var weeklyClosingTimes:[Date?]
    var weeklyByAppointment:[Bool]
    let latitude: Double?
    let longitude: Double?
    
    init(name: String, campusLocation: String?, phoneNumber: String?, weeklyOpeningTimes:[Date?], weeklyClosingTimes:[Date?], weeklyByAppointment:[Bool], imageLink: String?, latitude: Double?, longitude: Double?) {
        self.campusLocation = campusLocation
        self.phoneNumber = phoneNumber
        self.weeklyOpeningTimes = weeklyOpeningTimes
        self.weeklyClosingTimes = weeklyClosingTimes
        self.weeklyByAppointment = weeklyByAppointment
        self.latitude = latitude
        self.longitude = longitude
        
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }
    
    var isOpen: Bool {
        
        //Determining Status of library
        let todayDate = NSDate()
        
        if (weeklyClosingTimes[0] == nil) {
            return false
        }
        if (weeklyClosingTimes[0]!.compare(todayDate as Date) == .orderedAscending) {
            return false
        }
        
        return true
    }

}
