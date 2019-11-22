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
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(displayP3Red: 69/255, green: 68/255, blue: 68/255, alpha: 1.0) :
                    UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            }
        }
        return UIColor.white
    }
    
    static var searchBarIconColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.darkGray
            }
        }
        return UIColor.darkGray
    }
    
    static var modalBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(displayP3Red: 69/255, green: 68/255, blue: 68/255, alpha: 1.0) :
                    UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            }
        }
        return UIColor.white
    }
    
    static var cardBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(displayP3Red: 72/255, green: 71/255, blue: 71/255, alpha: 1.0) :
                    UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            }
        }
        return UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    }
    
    static var cellBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(displayP3Red: 64/255, green: 63/255, blue: 63/255, alpha: 1.0) :
                    UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            }
        }
        return UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    }
    
    static var primaryText: UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ?
                    UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0) :
                    UIColor(displayP3Red: 35/255, green: 35/255, blue: 35/255, alpha: 1.0)
            }
        }
        return UIColor(displayP3Red: 35/255, green: 35/255, blue: 35/255, alpha: 1.0)
    }

    static var secondaryText: UIColor { return UIColor(displayP3Red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0) }
}

