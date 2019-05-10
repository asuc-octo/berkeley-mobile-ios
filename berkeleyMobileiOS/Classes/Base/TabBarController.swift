//
//  TabBarController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/5/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material

fileprivate let kColorSelected = UIColor(hex: "2B90E2")
fileprivate let kColorDeselected = UIColor(hex: "BDBDBD")

protocol TabBarControllerView: class {
    /// The icon to display on the tab bar for the conforming view.
    var tabBarIcon: UIImage? { get }
}

class TabBarController: PageTabBarController {
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return viewControllers[selectedIndex]
    }
    
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
        
        self.viewControllers.forEach {
            let item = $0.pageTabBarItem
            item.imageView?.contentMode = .scaleAspectFit
            if let vc = $0 as? TabBarControllerView {
                item.image = vc.tabBarIcon?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    func highlightTabItem(of viewController: UIViewController) {
        let controllers = self.viewControllers
        guard controllers.contains(viewController) else {
            return
        }
        
        controllers.forEach {
            let item = $0.pageTabBarItem
            item.imageView?.tintColor = kColorDeselected
            item.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
        }
        
        let selectedItem = viewController.pageTabBarItem
        selectedItem.imageView?.tintColor = kColorSelected
        selectedItem.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
    }
}

extension TabBarController: PageTabBarControllerDelegate {
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        self.setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: 0.2) {
            self.highlightTabItem(of: viewController)
        }
        
    }
}
