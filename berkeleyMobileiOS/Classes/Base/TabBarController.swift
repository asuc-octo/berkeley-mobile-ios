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
        self.pageTabBar.lineColor = Color.white
        self.pageTabBar.lineHeight = 0
        pageTabBar.lineAlignment = .bottom
        pageTabBarItem.pulseAnimation = .center
        pageTabBarItem.pulseColor = Color.blue.lighten2
    }
}
extension TabBarController: PageTabBarControllerDelegate {
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {

        
        print(pageTabBarController.pageTabBar.lineColor)
    }
}
