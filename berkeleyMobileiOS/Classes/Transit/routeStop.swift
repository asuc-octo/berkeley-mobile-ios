//
//  routeStop.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 3/2/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class routeStop: NSObject {

    var name: String
    var latitude: Double
    var longitude: Double
    var id: Int
    init(_ name: String, _ latitude: Double, _ longitude: Double, _ id: Int) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
    }
}
