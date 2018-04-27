//
//  SearchDataSource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

fileprivate let kSearchEndpoint = secretKAPIURL + "/search_items"

class SearchDataSource {
    
    typealias ResourceType = Library
    
    // Fetch the list of libraries and report back to the completionHandler.
    static func fetchSearchItems(_ completion: @escaping ([SearchItem]?) -> Void)
    {
        Alamofire.request(kSearchEndpoint).responseJSON
            { response in
                
                if response.result.isFailure {
                    print("[Error @ SearchDataSource.fetchSearchItems()]: request failed")
                    return
                }
                
                let searchItems = JSON(data: response.data!)["search_list"].map { (_, child) in parseSearchItem(child) }
                completion(searchItems)
        }
    }
    
    // Return a SearchItem object parsed from JSON.
    private static func parseSearchItem(_ json: JSON) -> SearchItem
    {
        let searchItem = SearchItem(name: json["name"].stringValue, category: json["category"].stringValue, query: json["query"].stringValue)
        return searchItem
    }
}
