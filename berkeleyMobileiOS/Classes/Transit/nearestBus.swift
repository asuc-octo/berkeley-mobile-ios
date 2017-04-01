//
//  nearestBus.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 1/17/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import Foundation

class nearestBus: NSObject {
    var directionTitle: String = ""
    var busName: String = ""
    var timeLeft: [String]
    init(directionTitle: String, busName: String, timeLeft: String) {
        self.directionTitle = directionTitle
        self.busName = busName
        self.timeLeft = []
        self.timeLeft.append(timeLeft)
    }
    func addTime(_ timeLeft: String) {
        self.timeLeft.append(timeLeft)
    }
}
