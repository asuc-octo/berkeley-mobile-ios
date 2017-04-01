//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class Library: Resource {
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
        super.init(name: name, type:ResourceType.Library, imageLink: imageLink)
    }
    
    override var isOpen: Bool {
        
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
