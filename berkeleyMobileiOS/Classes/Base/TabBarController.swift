//
//  TabBarController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/5/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material

class TabBarController: PageTabBarController {
    open override func prepare() {
        super.prepare()
        
        delegate = self
        preparePageTabBar()
        
    }
    private func preparePageTabBar() {
        pageTabBar.height = 60
        self.pageTabBar.lineColor = Color.white
        self.pageTabBar.lineHeight = 0
        pageTabBar.lineAlignment = .bottom
        pageTabBarItem.pulseAnimation = .center
        pageTabBarItem.pulseColor = Color.blue.lighten2
        
        pageTabBarItem.tintColor = UIColor(hue: 0.5583, saturation: 0.79, brightness: 0.97, alpha: 1.0)
        if pageTabBarItem.isSelected {
            pageTabBarItem.backgroundColor = UIColor(hue: 0.5583, saturation: 0.79, brightness: 0.97, alpha: 1.0)
        }
    }
}
extension TabBarController: PageTabBarControllerDelegate {
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
    }
}
