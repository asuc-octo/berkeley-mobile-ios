//
//  Resource.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/28/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class Resource: NSObject {
    let name: String
    let imageURL: URL?
    
    public init(name: String, imageLink: String?) {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
    }

    var isOpen: Bool
    {
        return true
        // TODO: uncomment after Dennis merges the Date extension
        //        let now = Date()
        //        return now.isBetween(self.openingTimeToday, closingTimeToday)
        
    }
}
