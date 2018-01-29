//
//  Library.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class Library: Resource {
    var image: UIImage?
    
    
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
        
        
        
        
        
        var status = true
//        let dates: [Date?] = self.weeklyClosingTimes
//        if let l = dates.last! {
//            if (l.compare(NSDate() as Date) == .orderedAscending) {
//                status = false
//            }
//        } else {
//            status = false
//        }
//        return status
        let dow = Calendar.current.component(.weekday, from: Date())
        let translateddow = (dow - 2 + 7) % 7
        if let t = (self.weeklyOpeningTimes[translateddow]) {
            if t > Date() {
                status = false
            }
        }
        if let t = (self.weeklyClosingTimes[translateddow]) {
            if t < Date() {
                status = false
            }
        }
        return status
//        //Determining Status of library
//        let todayDate = NSDate()
//
//        if (weeklyClosingTimes[0] == nil) {
//            return false
//        }
//        if (weeklyClosingTimes[0]!.compare(todayDate as Date) == .orderedAscending) {
//            return false
//        }
//
//        return true
    }

}
