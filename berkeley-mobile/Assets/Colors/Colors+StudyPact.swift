//
//  Colors+StudyPact.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 11/14/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension Color {

    static var onboardingTint: UIColor {
        return UIColor(red: 0.337254902, green: 0.4352941176, blue: 0.7254901961, alpha: 1)
    }
    
    static var pageViewBackgroundTint: UIColor {
        return UIColor(displayP3Red: 86/255, green: 111/255, blue: 185/255, alpha: 1)
    }
    
    static var getStartedButton: UIColor {
        return UIColor(red: 0.3191883862, green: 0.4302733541, blue: 0.7476411462, alpha: 1)
    }
    
    struct StudyGroups {
        static var createGroupDottedBorder: UIColor {
            return UIColor(red: 158.0 / 255.0, green: 158.0 / 255.0, blue: 158.0 / 255.0, alpha: 1.0)
        }
        
        static var createGroupGreenPlus: UIColor {
            return UIColor(red: 163.0 / 255.0, green: 206.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
        }
    }
}