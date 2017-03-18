//
//  GymClassCategory.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymClassCategory: Resource {
    
    var favorited: Bool? = false

    init(name: String, imageLink: String) {
        super.init(name: name, type: ResourceType.GymClass, imageLink: imageLink)
    }
}
