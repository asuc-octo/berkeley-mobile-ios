//
//  Route.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 3/2/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import SwiftyJSON
class Route: NSObject {
    var busName: String
    var stops: [routeStop]
    var secondRouteStops: [routeStop]?
    var startTime: String
    var endTime: String
    var startTime2: String?
    var endTime2: String?
    var twoTrips: Bool
    var secondBusName: String?
    
    init(withOneStop busName: String, _ route1Stops: [routeStop], _ startTime: String, _ endTime: String) {
        self.busName = busName
        self.stops = route1Stops
        self.twoTrips = false
        //TODO turn start and end time into strings
        self.startTime = startTime
        self.endTime = endTime
    }
    init(withTwoStops busName: String, _ route1Stops: [routeStop], _ route2Stops: [routeStop], _ startTime: String, _ endTime: String, _ startTime2: String, _ endTime2: String, _ secondBusName: String) {
        self.busName = busName
        self.stops = route1Stops
        self.secondRouteStops = route2Stops
        self.twoTrips = true
        self.secondBusName = secondBusName
        //TODO turn start and end time into strings
        self.startTime = startTime
        self.endTime = endTime
        self.startTime2 = startTime2
        self.endTime2 = endTime2
    }
    func populateStopsAlongRoute(_ stops: [routeStop], _ currentBusName: String) -> [routeStop]{
        
        let firstStopID = stops.first!.name
        let lastStop = stops.last!.name
        var allStops: [routeStop] = []
        
        
        //Find the line
        var stopList: [[String: Any]] = ConvenienceMethods.getAllBTStops()[currentBusName]!["stop_list"] as! [[String : Any]]
        var firstIndex = 0
        //Find First stop's index
        for i in 0...stopList.count {
            let currentID = stopList[i]["name"] as! String
            if currentID == firstStopID {
                firstIndex = i
                break
            }
        }
        //Iterate through adding stops to the in between list until you get to the last stop
        var iterator = firstIndex
        while true {
            let currentStopObject = stopList[iterator]
            allStops.append(routeStop.init(currentStopObject["name"] as! String, currentStopObject["latitude"] as! Double, currentStopObject["longitude"] as! Double, currentStopObject["id"] as! Int))
            iterator = (iterator + 1) % stopList.count
            let nextStopObject = stopList[iterator]
            if nextStopObject["name"] as! String == lastStop {
                allStops.append(routeStop.init(nextStopObject["name"] as! String, nextStopObject["latitude"] as! Double, nextStopObject["longitude"] as! Double, nextStopObject["id"] as! Int))
                break
            }
        }
        return allStops
    }
    func populateStopsAlongAllRoutes() {
        self.stops = self.populateStopsAlongRoute(self.stops, self.busName)
        if twoTrips {
            self.secondRouteStops = self.populateStopsAlongRoute(self.secondRouteStops!, self.secondBusName!)
        }
    }
}
