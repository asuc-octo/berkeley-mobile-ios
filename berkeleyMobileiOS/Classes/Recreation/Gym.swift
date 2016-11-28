//
//  Gym.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation

class Gym: NSObject {
    
    let name: String
    let address: String
    let imageURL: URL
    
    var openingTimeToday: Date? = nil
    var closingTimeToday: Date? = nil
    
    init(name: String, address: String, imageLink: String, openingTimeToday: Date?, closingTimeToday: Date?) {
        self.name = name
        self.address = address
        self.imageURL = URL(string: imageLink)!
        self.openingTimeToday = openingTimeToday
        self.closingTimeToday = closingTimeToday
    }
    
    var isOpen: Bool
    {
        return true
        // TODO: uncomment after Dennis merges the Date extension
//        let now = Date()
//        return now.isBetween(self.openingTimeToday, closingTimeToday)
    }
}
