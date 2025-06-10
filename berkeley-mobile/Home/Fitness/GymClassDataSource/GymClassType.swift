//
//  GymClassType.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

enum GymClassType: String {
    
    case allAround = "ALL-AROUND WORKOUT"
    case cardio = "CARDIO"
    case mindBody = "MIND/BODY"
    case core = "CORE"
    case dance = "DANCE"
    case strength = "STRENGTH"
    case aqua = "AQUA"
    
    var color: UIColor {
        switch self {
        case .allAround:
            return BMColor.classAllAround
        case .cardio:
            return BMColor.classCardio
        case .mindBody:
            return BMColor.classMindBody
        case .core:
            return BMColor.classCore
        case .dance:
            return BMColor.classDance
        case .strength:
            return BMColor.classStrength
        case .aqua:
            return BMColor.classAqua
        }
    }
    
}
