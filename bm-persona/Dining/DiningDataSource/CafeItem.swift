//
//  CafeItem.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

/** CafeMenu is a typealias for an array of CafeItems. */
typealias CafeMenu = Array<CafeItem>

/** Object representing a single dish/item. */
class CafeItem {
    
    let name: String
    let cost: Double
    var isFavorited: Bool = false
    
    // Additional information regarding food such as allergens or alternative options
    let restrictions: [DiningRestriction]
    
    init(name: String, cost: Double, restrictions: [String]) {
        self.name = name
        self.cost = cost
        self.restrictions = restrictions.map { (rawValue) -> DiningRestriction in
            return DiningRestriction(rawValue: rawValue)
        }
    }
}
