//
//  Colors.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//
 
import Foundation
import UIKit

struct Color {
    
    static var searchBarBackground: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: 69/255, green: 68/255, blue: 68/255, alpha: 1.0) :
                UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        }
    }
    
    static var searchBarIconColor: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.darkGray
        }
    }

    static var mapAnnotationColor: UIColor {
        return UIColor(displayP3Red: 129/255, green: 164/255, blue: 255/255, alpha: 1.0)
    }
    
    static var modalBackground: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0) :
                UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        }
    }
    
    static var cardBackground: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: 72/255, green: 71/255, blue: 71/255, alpha: 1.0) :
                UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
    }
    
    static var cellBackground: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: 64/255, green: 63/255, blue: 63/255, alpha: 1.0) :
                UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
    }
    
    static var selectedButtonBackground: UIColor {
        return UIColor(displayP3Red: 251/255, green: 155/255, blue: 142/255, alpha: 1.0)
    }
    
    static func barGraphEntry(alpha: CGFloat) -> UIColor {
        return UIColor(displayP3Red: 248/255, green: 162/255, blue: 150/255, alpha: alpha)
    }
    
    static var barGraphEntryCurrent: UIColor {
        return UIColor(displayP3Red: 119/255, green: 154/255, blue: 252/255, alpha: 1.0)
    }

    static var segmentedControlHighlight: UIColor {
        return UIColor(displayP3Red: 250/255, green: 212/255, blue: 126/255, alpha: 1.0)
    }
}

