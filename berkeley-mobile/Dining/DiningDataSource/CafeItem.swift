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
class CafeItem: DiningItem {
    
    let cost: Double
    
    init(name: String, cost: Double, restrictions: [String]) {
        self.cost = cost
        super.init(name: name, restrictions: restrictions)
    }
}
