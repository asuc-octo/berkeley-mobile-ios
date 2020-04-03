//
//  GymClass.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/13/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

class GymClass {
    
    let name: String
    
    var start_time: Date
    var end_time: Date
    
    var class_type: String?
    var location: String?
    var trainer: String?

    init(name: String, start_time: Date, end_time: Date, class_type: String?, location: String?, trainer: String?) {
        self.name = name
        self.start_time = start_time
        self.end_time = end_time
        self.class_type = class_type
        self.location = location
        self.trainer = trainer
    }
}
