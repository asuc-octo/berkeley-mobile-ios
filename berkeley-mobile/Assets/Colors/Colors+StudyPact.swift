//
//  Colors+StudyPact.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 11/14/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension BMColor {
    struct StudyPact {
        struct Onboarding {
            static var pink: UIColor {
                return UIColor(displayP3Red: 251/255, green: 155/255, blue: 142/255, alpha: 1.0)
            }
            static var yellow: UIColor {
                return UIColor(displayP3Red: 253/255, green: 189/255, blue: 34/255, alpha: 1.0)
            }
            static var blue: UIColor {
                return UIColor(displayP3Red: 106/255, green: 145/255, blue: 255/255, alpha: 1.0)
            }
            static var getStartedBlue: UIColor {
                return UIColor(displayP3Red: 114/255, green: 151/255, blue: 230/255, alpha: 1.0)
            }
            
            static var pageViewBackgroundTint: UIColor {
                return UIColor(displayP3Red: 86/255, green: 111/255, blue: 185/255, alpha: 1)
            }
        }
        
        struct CreatePreference {
            static var selectedPink: UIColor {
                return UIColor(displayP3Red: 238/255, green: 145/255, blue: 145/255, alpha: 1.0)
            }
            
            static var disabledNextbutton: UIColor {
                return UIColor(displayP3Red: 199/255, green: 199/255, blue: 199/255, alpha: 1.0)
            }
            
            static var enabledNextButton: UIColor {
                return UIColor(red: 0.3191883862, green: 0.4302733541, blue: 0.7476411462, alpha: 1)
            }
            
            static var grayText: UIColor {
                return UIColor(displayP3Red: 103/255, green: 103/255, blue: 103/255, alpha: 1.0)
            }
            
            static var selectedBlue: UIColor {
                return UIColor(displayP3Red: 119/255, green: 154/255, blue: 252/255, alpha: 1.0)
            }
        }
        
        struct StudyGroups {
            static var createPreferenceDottedBorder: UIColor {
                return UIColor(red: 158.0 / 255.0, green: 158.0 / 255.0, blue: 158.0 / 255.0, alpha: 1.0)
            }
            
            static var createPreferenceGreenPlus: UIColor {
                return UIColor(red: 163.0 / 255.0, green: 206.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
            }
            
            static var getStartedButton: UIColor {
                return UIColor(displayP3Red: 251/255, green: 155/255, blue: 142/255, alpha: 1.0)
            }
            
            static var getStartedPressed: UIColor {
                return UIColor(red: 225/255, green: 124/255, blue: 110/255, alpha: 1)
            }
            
            static var pendingLabel: UIColor {
                return UIColor(displayP3Red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
            }
            
            static var leaveGroupButton: UIColor {
                return UIColor(displayP3Red: 199/255, green: 199/255, blue: 199/255, alpha: 1.0)
            }

            static var enabledButton: UIColor {
                return UIColor(displayP3Red: 127/255, green: 153/255, blue: 245/255, alpha: 1.0)
            }

            static var disabledButton: UIColor {
                return UIColor(displayP3Red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
            }
        }
        
        struct Profile {
            static var defaultProfileLetter: UIColor {
                return UIColor(displayP3Red: 255/255, green: 192/255, blue: 183/255, alpha: 1.0)
            }
            
            static var defaultProfileBackground: UIColor {
                return UIColor(displayP3Red: 235/255, green: 154/255, blue: 154/255, alpha: 1.0)
            }
        }
    }
}
