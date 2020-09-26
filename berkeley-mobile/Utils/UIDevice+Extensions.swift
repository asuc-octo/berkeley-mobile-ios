//
//  UIDevice+Extensions.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 9/22/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            if UIApplication.shared.windows.count == 0 { return false }
            let top = UIApplication.shared.windows.first!.safeAreaInsets.top
            return top > 20
        } else {
            // Fallback on earlier versions
            return false
        }
    }
}
