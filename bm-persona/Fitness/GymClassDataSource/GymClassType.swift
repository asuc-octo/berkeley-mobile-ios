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
            return Color.classAllAround
        case .cardio:
            return Color.classCardio
        case .mindBody:
            return Color.classMindBody
        case .core:
            return Color.classCore
        case .dance:
            return Color.classDance
        case .strength:
            return Color.classStrength
        case .aqua:
            return Color.classAqua
        }
    }
    
}
