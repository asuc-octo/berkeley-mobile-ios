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
            return UIColor(displayP3Red: 52/255, green: 52/255, blue: 52/255, alpha: 1.0)
        }
        
        static var blackText: UIColor {
            return UIColor(displayP3Red: 17/255, green: 17/255, blue: 18/255, alpha: 1.0)
        }
        
    }
}
