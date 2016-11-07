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
        var count = 0
        for vc in (pageTabBarVC.viewControllers) {
            if (vc == selectedViewController)   {
                //Make Current Tab Image Bigger
                vc.pageTabBarItem.imageEdgeInsets = UIEdgeInsetsMake(3,3,3,3)
                vc.pageTabBarItem.imageView?.tintColor = Color.blue.base
            } else {
                vc.pageTabBarItem.imageEdgeInsets = UIEdgeInsetsMake(6,6,6,6)
                vc.pageTabBarItem.imageView?.tintColor = Color.grey.base

            }
            count += 1
        }
    }
}
