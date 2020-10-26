//
//  Colors+ActionButton.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/10/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension Color {
    /// Colors for the `ActionButton` class.
    struct ActionButton {

        /// The color of the text for the button.
        static var color: UIColor {
            return UIColor(displayP3Red: 254/255, green: 254/255, blue: 254/255, alpha: 1.0)
        }

        /// The background color for the button in its default state.
        static var background: UIColor {
            return UIColor(displayP3Red: 119/255, green: 154/255, blue: 252/255, alpha: 1.0)
        }

        /// The background color for the button in its highlighted state.
        static var highlighted: UIColor {
            return UIColor(displayP3Red: 96/255, green: 125/255, blue: 204/255, alpha: 1.0)
        }
    }
}
