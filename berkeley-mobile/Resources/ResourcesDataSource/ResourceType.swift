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

    var color: UIColor {
        switch self {
        case .health:
            return BMColor.Resource.health
        case .mentalHealth:
            return BMColor.Resource.mentalHealth
        case .basicNeeds:
            return BMColor.Resource.basicNeeds
        case .admin:
            return BMColor.Resource.admin
        }
    }

}
