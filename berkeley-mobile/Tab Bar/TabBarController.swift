//
//  TabBarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let mapView = MainContainerViewController()
    let resourcesView = ResourcesViewController()
    let calendarView = CalendarViewController()
    let profileView = ProfileViewController()
    
    static var homePressedMessage = "dismissDrawerWithHomePress"

    override func viewDidLoad() {
        super.viewDidLoad()
                
        delegate = self
        tabBar.isTranslucent = false
        tabBar.tintColor = BMColor.blackText
        
        let tabBarAppearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: Font.regular(11)]
        tabBarAppearance.setTitleTextAttributes(attributes, for: .normal)
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = BMColor.cardBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        mapView.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "Home"), tag: 0)
        resourcesView.tabBarItem = UITabBarItem(title: "Resources", image: UIImage(named: "Resources"), tag: 1)
        calendarView.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "Calendar"), tag: 2)
        profileView.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile"), tag: 3)
        
        self.viewControllers = [mapView, resourcesView, calendarView, profileView]
        
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.selectedViewController == mapView {
            if item.tag == 0 {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(TabBarController.homePressedMessage), object: nil)
            }
        }
    }
    
    public func selectProfileTab() {
        if let profileIndex = self.viewControllers?.firstIndex(of: profileView) {
            self.selectedIndex = profileIndex
        }
    }
    
    public func selectMainTab() {
        if let mainIndex = self.viewControllers?.firstIndex(of: mapView) {
            self.selectedIndex = mainIndex
        }
    }
}
