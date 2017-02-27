//
//  GymClass.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import Foundation

class GymClass: Resource {
    
    var date: Date? = nil
    var start_time: Date? = nil
    var end_time: Date? = nil
    var class_type: String? = nil
    var location: String? = nil
    var trainer: String? = nil

    init(name: String, class_type:String, location: String, trainer: String, date: Date?, start_time: Date?, end_time: Date?, imageLink: String) {
        self.start_time = start_time
        self.end_time = end_time
        self.date = date
        self.class_type = class_type
        self.location = location
        self.trainer = trainer
        
        super.init(name: name, imageLink: imageLink)
    }


}
