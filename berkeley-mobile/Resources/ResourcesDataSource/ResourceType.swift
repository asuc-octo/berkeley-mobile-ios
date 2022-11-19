//
//  ResourceType.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 12/5/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

enum ResourceType: String {

    case health = "Health"
    case mentalHealth = "Mental Health"
    case basicNeeds = "Basic Needs"
    case admin = "Admin"
    case safety = "Safety"

    var color: UIColor {
        switch self {
        case .health:
            return Color.Resource.health
        case .mentalHealth:
            return Color.Resource.mentalHealth
        case .basicNeeds:
            return Color.Resource.basicNeeds
        case .admin:
            return Color.Resource.admin
        case .safety:
            return Color.Resource.safety
        }
    }

}
