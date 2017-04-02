//
//  nearestStopsDataSource
//  berkeleyMobileiOS
//
//  Created by Akilesh on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

fileprivate let kGymsEndpoint = "https://asuc-mobile-development.herokuapp.com/api/bt_lines"
fileprivate let getRouteEndpoint = "https://asuc-mobile-development.herokuapp.com/api/bt_trips/new?"

class fullRouteDataSource: NSObject {
    typealias completionHandler = (_ buses: [Route]) -> Void
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchBuses(_ completion: @escaping completionHandler, startLat: String, startLon: String, destLat: String, destLon: String)
    {
        Alamofire.request(getRouteEndpoint, method: .get, parameters: ["startlat": startLat, "startlon": startLon, "destlat": destLat, "destlon": destLon]).responseJSON
            { response in
                if response.result.isFailure {
                    print("Error: Failed TO GET BUSES")
                    let buses: [Route] = []
                    completion(buses)
                } else {
                    let routesJSON = JSON(data: response.data!)["journeys"]
                    completion(routesJSON.map { (_, child) in parseRoute(child) })

                }
                
                
        }

    }
    
    private static func makeRouteObjectFromTrip(_ json: JSON) -> Route {
        let tripObject = json["trip_list"].array!
        let desiredTrip = tripObject[0]
        let fullBusName = desiredTrip["line_name"].stringValue
        let startObject = routeStop.init(desiredTrip["starting_stop"]["name"].stringValue, desiredTrip["starting_stop"]["latitude"].doubleValue, desiredTrip["starting_stop"]["longitude"].doubleValue, desiredTrip["starting_stop"]["id"].intValue)
        let endObject = routeStop.init(desiredTrip["destination_stop"]["name"].stringValue, desiredTrip["destination_stop"]["latitude"].doubleValue, desiredTrip["destination_stop"]["longitude"].doubleValue, desiredTrip["destination_stop"]["id"].intValue)
        let startTime = desiredTrip["departure_time"].stringValue
        let endTime = desiredTrip["arrival_time"].stringValue
        var routeObj: Route
        if tripObject.count == 2 {
            let desiredTrip = tripObject[1]
            let start2Object = routeStop.init(desiredTrip["starting_stop"]["name"].stringValue, desiredTrip["starting_stop"]["latitude"].doubleValue, desiredTrip["starting_stop"]["longitude"].doubleValue, desiredTrip["starting_stop"]["id"].intValue)
            let end2Object = routeStop.init(desiredTrip["destination_stop"]["name"].stringValue, desiredTrip["destination_stop"]["latitude"].doubleValue, desiredTrip["destination_stop"]["longitude"].doubleValue, desiredTrip["destination_stop"]["id"].intValue)
            let startTime2 = desiredTrip["departure_time"].stringValue
            let endTime2 = desiredTrip["arrival_time"].stringValue
            let busName2 = desiredTrip["line_name"].stringValue
            routeObj = Route.init(withTwoStops: fullBusName, [startObject, endObject], [start2Object, end2Object], startTime, endTime, startTime2, endTime2, busName2)
        } else {
            routeObj = Route.init(withOneStop: fullBusName, [startObject, endObject], startTime, endTime)
        }
        return routeObj
    }
    // Return a Gym object parsed from JSON.
    private static func parseRoute(_ json: JSON) -> Route
    {
        var routeObject = makeRouteObjectFromTrip(json)
        //Turn Start/Stop Array into the whole range of stops
        routeObject.populateStopsAlongAllRoutes()
        
        return routeObject
    }
    
}
