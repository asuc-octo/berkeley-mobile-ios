//
//  DiningItem.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

/** DiningMenu is a typealias for an array of DiningItems. */
typealias DiningMenu = Array<DiningItem>

/** Object representing a single dish/item. */
class DiningItem: HasName {
    
    @Display var name: String
    var isFavorited: Bool = false
    
    // Additional information regarding food such as allergens or alternative options
    let restrictions: [DiningRestriction]
    
    init(name: String, restrictions: [String]) {
        self.name = name
        self.restrictions = restrictions.map { (rawValue) -> DiningRestriction in
            return DiningRestriction(rawValue: rawValue)
        }
    }
}

