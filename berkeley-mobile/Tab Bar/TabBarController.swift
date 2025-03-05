//
//  TabBarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import SwiftUI

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let mapView = MainContainerViewController()
    let calendarView = UIHostingController(rootView: EventsView())
    let safetyView = UIHostingController(rootView: SafetyView())
    let resourcesView = UIHostingController(rootView: ResourcesView())
    
    static var homePressedMessage = "dismissDrawerWithHomePress"

    override func viewDidLoad() {
        super.viewDidLoad()
                
        delegate = self
        tabBar.isTranslucent = false
        tabBar.tintColor = BMColor.blackText
        
        let tabBarAppearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: BMFont.regular(11)]
        tabBarAppearance.setTitleTextAttributes(attributes, for: .normal)
        tabBar.isTranslucent = true
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = BMColor.cardBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        mapView.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "Home"), tag: 0)
        calendarView.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "Calendar"), tag: 1)
        safetyView.tabBarItem = UITabBarItem(title: "Safety", image: UIImage(systemName: "exclamationmark.shield"), tag: 2)
        resourcesView.tabBarItem = UITabBarItem(title: "Resources", image: UIImage(systemName: "tray.full"), tag: 3)
        
        self.viewControllers = [mapView, calendarView, safetyView, resourcesView]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.selectedViewController == mapView {
            if item.tag == 0 {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(TabBarController.homePressedMessage), object: nil)
            }
        }
    }
    
    public func selectMainTab() {
        if let mainIndex = self.viewControllers?.firstIndex(of: mapView) {
            self.selectedIndex = mainIndex
        }
    }
}
