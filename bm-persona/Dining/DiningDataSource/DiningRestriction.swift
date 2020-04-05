//
//  DiningRestriction.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

// The set of known restrictions. The `rawValue` is the string representation in Firebase.
enum KnownRestriction: String, CaseIterable {
    
    case alcohol    = "Contains Alcohol"
    case egg        = "Egg"
    case fish       = "Fish"
    case gluten     = "Contains Gluten"
    case halal      = "Halal"
    case kosher     = "Kosher"
    case milk       = "Milk"
    case peanut     = "Peanuts"
    case pork       = "Contains Pork"
    case sesame     = "Sesame"
    case shellfish  = "Shellfish"
    case soybean    = "Soybeans"
    case treenut    = "Tree Nuts"
    case vegan      = "Vegan Option"
    case vegetarian = "Vegetarian Option"
    case wheat      = "Wheat"
    
}

// Handles both known and unknown restrictions
class DiningRestriction {
    
    var rawValue: String
    // `nil` if restriction is unknown.
    var known: KnownRestriction?
    
    init(rawValue: String) {
        self.rawValue = rawValue
        self.known = KnownRestriction(rawValue: rawValue)
    }
    
    var icon: UIImage? {
        guard let restriction = known else { return nil }
        switch restriction {
        // TODO: Fill out
        case .alcohol:
            return UIImage()
        default:
            return UIImage()
        }
    }
    
}

extension DiningRestriction {
    
    static func == (lhs: DiningRestriction, rhs: DiningRestriction) -> Bool {
         return lhs.rawValue == rhs.rawValue
    }
    
    static func == (lhs: DiningRestriction, rhs: KnownRestriction) -> Bool {
         return lhs.rawValue == rhs.rawValue
    }
    
}
