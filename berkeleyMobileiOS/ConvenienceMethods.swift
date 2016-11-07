//
//  ConvenienceMethods.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/6/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Material

class ConvenienceMethods: NSObject {
    static func setCurrentTabStyle(pageTabBarVC: PageTabBarController, ForSelectedViewController selectedViewController: UIViewController) {
        for vc in (pageTabBarVC.viewControllers) {
            if (vc == selectedViewController)   {
                vc.pageTabBarItem.imageView?.tintColor = Color.blue.base
            } else {
                vc.pageTabBarItem.imageView?.tintColor = Color.grey.base
            }
        }
    }
}
