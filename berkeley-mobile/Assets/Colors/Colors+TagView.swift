//
//  Colors+TagView.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/15/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

// Colors for commonly-used TagViews
extension Color {
    
    static var openTag: UIColor {
        return UIColor(displayP3Red: 133/255, green: 158/255, blue: 248/255, alpha: 1.0)
    }
    
    static var closedTag: UIColor {
        return UIColor(displayP3Red: 133/255, green: 158/255, blue: 248/255, alpha: 1.0)
    }
    
    static var highOccupancyTag: UIColor {
        return UIColor(red: 221/255, green: 67/255, blue: 67/255, alpha: 1)
    }
    
    static var medOccupancyTag: UIColor {
        return UIColor(red: 251/255, green: 179/255, blue: 43/255, alpha: 1)
    }
    
    static var lowOccupancyTag: UIColor {
        return UIColor(red: 162/255, green: 183/255, blue: 14/255, alpha: 1)
    }
    
    static var pendingTag: UIColor {
        return UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1)
    }
}
