//
//  SearchItem.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//
import Alamofire
import SwiftyJSON

fileprivate let kURL = "https://asuc-mobile-development.herokuapp.com"

class SearchItem {

    let name: String?
    let category: String?
    var query: String?
    
    init(name: String, category: String?, query: String?) {
        self.name = name
        self.category = category
        self.query = query
    }
    
    func detailedData(_ completion: @escaping (Resource?) -> Void)  {
        guard self.query != nil else {
            return
        }
        guard self.category != nil else {
            return
        }
        
        let url = kURL + self.query!
        
        var resourceType: ResourceType
        var key: String
        
        switch category! {
        case "Dining Hall":
            resourceType = ResourceType.DiningHall
            key = "dining_hall"
        case "Library":
            resourceType = ResourceType.Library
            key = "library"
        case "Gym":
            resourceType = ResourceType.Gym
            key = "gym"
        default:
            return
        }
        
        Alamofire.request(url).responseJSON
            { response in
                
                if response.result.isFailure {
                    print("[Error @ SearchItem.detailedData()]: request failed")
                    return
                }
                let json = JSON(data: response.data!)[key]
                let item = resourceType.dataSourceType.parseResource(json)
                completion(item)
        }
    }

}
