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
    init(_ lat: Double, _ lon: Double, _ ln: String) {
        self.latitude = lat
        self.longitude = lon
        self.lineName = ln
    }
}
