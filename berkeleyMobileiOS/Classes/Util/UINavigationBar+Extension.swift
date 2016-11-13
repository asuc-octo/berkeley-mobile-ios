//
//  UINavigationBar+Extension.swift
//  berkeleyMobileiOS
//
//  Created by Bohui Moon on 11/13/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit

fileprivate let kHairlineKey = "hidesShadow"

extension UINavigationBar
{
    open var hideHairline: Bool
    {
        set { self.setValue(newValue, forKey: kHairlineKey) }
        get { return self.value(forKey: kHairlineKey) as! Bool  }
    }
}
