//
//  livebus.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/9/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class livebus: NSObject {
    
    var latitude: Double
    var longitude: Double
    var lineName: String
    var id: String
    
    init(_ lat: Double, _ lon: Double, _ ln: String, _ id: String) {
        self.latitude = lat
        self.longitude = lon
        self.lineName = ln
        self.id = id
    }
}
