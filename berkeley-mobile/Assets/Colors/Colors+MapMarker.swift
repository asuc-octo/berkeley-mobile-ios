//
//  Colors+MapMarker.swift
//  bm-persona
//
//  Created by Kevin Hu on 9/14/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

extension Color {
    // Colors for Map Marker Categories
    struct MapMarker {

        static var microwave: UIColor {
            return UIColor(displayP3Red: 248/255, green: 95/255, blue: 73/255, alpha: 1.0)
        }

        static var rest: UIColor {
            return UIColor(displayP3Red: 253/255, green: 43/255, blue: 168/255, alpha: 1.0)
        }
        
        static var printer: UIColor {
            return UIColor(displayP3Red: 93/255, green: 187/255, blue: 68/255, alpha: 1.0)
        }

        static var water: UIColor {
            return UIColor(displayP3Red: 45/255, green: 121/255, blue: 176/255, alpha: 1.0)
        }

        static var bikes: UIColor {
            return UIColor(displayP3Red: 45/255, green: 53/255, blue: 255/255, alpha: 1.0)
        }

        static var lactation: UIColor {
            return UIColor(displayP3Red: 249/255, green: 134/255, blue: 49/255, alpha: 1.0)
        }

        static var waste: UIColor {
            return UIColor(displayP3Red: 101/255, green: 54/255, blue: 17/255, alpha: 1.0)
        }

        static var garden: UIColor {
            return UIColor(displayP3Red: 124/255, green: 190/255, blue: 49/255, alpha: 1.0)
        }

        static var cafe: UIColor {
            return UIColor(displayP3Red: 146/255, green: 83/255, blue: 163/255, alpha: 1.0)
        }

        static var store: UIColor {
            return UIColor(displayP3Red: 217/255, green: 125/255, blue: 228/255, alpha: 1.0)
        }

        static var other: UIColor {
            return UIColor(displayP3Red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
        }
    }
}
