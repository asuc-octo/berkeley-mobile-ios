//
//  Colors.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//
 
import Foundation
import SwiftUI
import UIKit

struct BMColor {
    
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
                UIColor(displayP3Red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0) :
                UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
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
    
    static var gradientDarkGrey: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: CGFloat(239) / 255.0 * 0.2, green: CGFloat(241) / 255.0 * 0.2, blue: CGFloat(241) / 255.0 * 0.2, alpha: 1.0) :
                UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        }
    }

    static var gradientLightGrey: UIColor {
        return UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ?
                UIColor(displayP3Red: CGFloat(201) / 255.0 * 0.5, green: CGFloat(201) / 255.0 * 0.5, blue: CGFloat(201) / 255.0 * 0.5, alpha: 1.0) :
                UIColor(displayP3Red: 201/255, green: 201/255, blue: 201/255, alpha: 1.0)
        }
    }
    
}


// MARK: - UIColor Extension

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
}

