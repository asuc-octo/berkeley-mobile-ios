//
//  Colors+Text.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/15/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

extension BMColor {
    
    static var primaryText: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0) :
                UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1.0)
        }
    }
    
    static var blackText: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0) :
                UIColor(red: 44/255, green: 44/255, blue: 45/255, alpha: 1.0)
        }
    }
    
    static var blueText: UIColor {
        return UIColor(red: 48.0 / 255.0, green: 80.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    }
    
    static var lightGrayText: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0) :
                UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        }
    }
    
    static var lightLightGrayText: UIColor {
        return UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
    }
    
    static var darkGrayText: UIColor {
        return UIColor(red: 138.0 / 255.0, green: 135.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
    }
    
    static var secondaryText: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0) :
                UIColor(displayP3Red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
        }
    }
    
}
