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

fileprivate let kGymsEndpoint = "https://asuc-mobile.herokuapp.com/api/bt_buses"

class livebusDataSource: NSObject {
    typealias completionHandler = (_ buses: [livebus]?) -> Void
    
    static func fetchBuses(_ completion: @escaping completionHandler)
    {
        Alamofire.request(kGymsEndpoint).responseJSON
            { response in
                
                if response.result.isFailure {
                    print("[Error @ GymDataSource.fetchGyms()]: request failed")
                    let buses: [livebus]? = []
                    completion(buses)
                } else {
                    var buses: [livebus] = []
                    let responseData = JSON(data:response.data!)["buses"]
                    for bus in responseData {
                        buses.append(livebus.init(bus.1["latitude"].doubleValue, bus.1["longitude"].doubleValue,bus.1["line_name"].stringValue, bus.1["id"].stringValue))
                    }
                    completion(buses)
                }
        }
    }
    
}

