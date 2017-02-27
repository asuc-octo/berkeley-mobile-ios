//
//  Gym.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation

class Gym: Resource {
    
    let address: String
    
    var openingTimeToday: Date? = nil
    var closingTimeToday: Date? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    init(name: String, address: String, imageLink: String, openingTimeToday: Date?, closingTimeToday: Date?) {
        self.address = address
        self.openingTimeToday = openingTimeToday
        self.closingTimeToday = closingTimeToday
        super.init(name: name, type: ResourceType.Gym, imageLink: imageLink)
    }

}
