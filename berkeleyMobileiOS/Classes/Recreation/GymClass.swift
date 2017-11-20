//
//  GymClass.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit
class GymClass: Resource {
    var image: UIImage?
    
    
    static func displayName(pluralized: Bool) -> String {
        return "Gym Class" + (pluralized ? "es" : "")
    }
    
    static var dataSource: ResourceDataSource.Type? = GymClassDataSource.self
    static var detailProvider: ResourceDetailProvider.Type? = GymClassViewController.self
    
    
    let name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false
    
    var date: Date? = nil
    var start_time: Date? = nil
    var end_time: Date? = nil
    var class_type: String? = nil
    var location: String? = nil
    var trainer: String? = nil
    
    var isOpen: Bool {
//        return Date().isBetween(start_time, end_time)
        
        return true
    }

    init(name: String, class_type:String, location: String, trainer: String, date: Date?, start_time: Date?, end_time: Date?, imageLink: String?) {
        self.start_time = start_time
        self.end_time = end_time
        self.date = date
        self.class_type = class_type
        self.location = location
        self.trainer = trainer

//        self.name = name
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }
}
