//
//  Colors+Calendar.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 11/21/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension Color {
    // Colors for Calendar elements
    struct Calendar {
        
        static var dayOfWeekHeader: UIColor {
            return UIColor(displayP3Red: 86/255, green: 112/255, blue: 185/255, alpha: 1.0)
        }
        
        static var grayedText: UIColor {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(displayP3Red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0) :
                    UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
            }
        }
        
        static var blackText: UIColor {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0) :
                    UIColor(red: 44/255, green: 44/255, blue: 45/255, alpha: 1.0)
            }
        }
        
    }
}
