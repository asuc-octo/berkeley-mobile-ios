//
//  Colors+Resource.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 12/5/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension Color {
    // Colors for Resource Types
    struct Resource {

        static var health: UIColor {
            UIColor(displayP3Red: 225/255, green: 77/255, blue: 77/255, alpha: 0.89)
        }

        static var finances: UIColor {
            UIColor(displayP3Red: 92/255, green: 198/255, blue: 175/255, alpha: 0.89)
        }

        static var admin: UIColor {
            UIColor(displayP3Red: 114/255, green: 151/255, blue: 230/255, alpha: 0.89)
        }

        static var basicNeeds: UIColor {
            UIColor(displayP3Red: 210/255, green: 95/255, blue: 223/255, alpha: 0.89)
        }

        static var legal: UIColor {
            UIColor(displayP3Red: 247/255, green: 148/255, blue: 106/255, alpha: 0.89)
        }
    }

}
