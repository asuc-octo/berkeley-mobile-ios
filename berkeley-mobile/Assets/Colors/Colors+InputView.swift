//
//  Colors+InputView.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/6/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension Color {
    // Colors for user input fields
    struct InputView {

        static var placeholder: UIColor {
            return UIColor(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        }

        static var unfocused: UIColor {
            return UIColor(displayP3Red: 209/255, green: 209/255, blue: 209/255, alpha: 1.0)
        }

        static var focused: UIColor {
            return UIColor(displayP3Red: 44/255, green: 44/255, blue: 45/255, alpha: 1.0)
        }

        static var selected: UIColor {
            return UIColor(displayP3Red: 106/255, green: 145/255, blue: 255/255, alpha: 1.0)
        }

        static var radioBorder: UIColor {
            return UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
        }

        struct Tag {

            static var cyan: UIColor {
                return UIColor(displayP3Red: 102/255, green: 188/255, blue: 236/255, alpha: 1.0)
            }

            static var yellow: UIColor {
                return UIColor(displayP3Red: 244/255, green: 196/255, blue: 121/255, alpha: 1.0)
            }

            // TODO: Fill out remaining tags.

            static var all: [UIColor] {
                return [cyan, yellow]
            }
        }
    }

}
