//
//  GymClassCategory.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymClassCategory: Resource {
    
    static func displayName(pluralized: Bool) -> String {
        return "Gym Class Categor" + (pluralized ? "ies" : "y")
    }
    
    static var dataSource: ResourceDataSource.Type? = GymClassCategoryDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = nil
    
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    var isOpen: Bool
    {
        return false; 
    }

    init(name: String, imageLink: String?)
    {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }
}
