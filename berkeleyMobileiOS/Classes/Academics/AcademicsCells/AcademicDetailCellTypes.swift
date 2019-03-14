//
//  AcademicDetailCellTypes.swift
//  berkeleyMobileiOS
//
//  Created by Kevin Hu on 3/12/19.
//  Copyright © 2019 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit

enum AcademicDetailCellTypes {
    case hours
    case weekly
    case phone
    case email
    case location
    case description
    case none
    
    var icon: UIImage? {
        switch self {
        case .hours:
            return UIImage(named: "hours_2.0.png")
        case .weekly:
            return UIImage(named: "hours_2.0.png")
        case .phone:
            return UIImage(named: "phone_2.0.png")
        case .email:
            return UIImage(named: "mail_2.0.png")
        case .location:
            return UIImage(named: "location_2.0.png")
        default:
            return UIImage(named: "info_2.0.png")
        }
    }
    
    var tappableType: TappableInfoType {
        switch self {
        case .phone:
            return .phone
        case .email:
            return .email
        default:
            return .none
        }
    }
}
