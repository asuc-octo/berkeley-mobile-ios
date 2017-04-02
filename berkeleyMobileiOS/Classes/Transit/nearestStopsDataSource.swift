//
//  nearestStopsDataSource
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

fileprivate let kGymsEndpoint = "https://asuc-mobile-development.herokuapp.com/api/pt_routes?code="

class nearestStopsDataSource: NSObject {
    typealias completionHandler = (_ buses: [nearestBus]?) -> Void
    
    // Fetch the list of gyms and report back to the completionHandler.
    static func fetchBuses(_ completion: @escaping completionHandler, stopCode: String)
    {
        Alamofire.request(kGymsEndpoint + stopCode).responseJSON
            { response in
                
                if response.result.isFailure {
                    print("[Error @ GymDataSource.fetchGyms()]: request failed")
                    let buses: [nearestBus]? = []
                    completion(buses)
                } else {
                    var busesDict: [String: nearestBus] = [:]
                    for stop in JSON(data: response.data!)["ptbus_response"]["values"] {
                        busesDict = parseBus(stop.1, busesDict)
                    }
                    var newBuses: [nearestBus] = []
                    for (key, value) in busesDict {
                        newBuses.append(value)
                    }
                    completion(newBuses)
                }
                

        }
    }
    
    // Return a Gym object parsed from JSON.
    private static func parseBus(_ json: JSON, _ busesDict: [String: nearestBus]) -> [String: nearestBus]
    {
        var editedBusesDict = busesDict
        let fullBusName = json["direction"]["id"].stringValue
        var busName = ""
        for busNameCharacter: Character in fullBusName.characters {
            if (busNameCharacter == "_") {
                break
            } else {
                busName += String(busNameCharacter)
            }
        }

        let secondsLeft = Int(json["seconds"].stringValue)
        let minutesLeft = secondsLeft! / 60
        let remainingSeconds = secondsLeft! % 60
        let timeLeft = String(minutesLeft) + ":" + String(remainingSeconds)
    
        if busesDict[busName] != nil {
            busesDict[busName]!.addTime(timeLeft)
        } else {
            let busObj = nearestBus(directionTitle: json["direction"]["title"].stringValue, busName: busName, timeLeft: timeLeft)
            editedBusesDict[busName] = busObj
        }

        return editedBusesDict
    }
    
}
