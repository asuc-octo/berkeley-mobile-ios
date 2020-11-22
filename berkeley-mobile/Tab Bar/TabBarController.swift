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
    
    static var homePressedMessage = "dismissDrawerWithHomePress"
    static var homePressedCollapseMessage = "collapseTopDrawer"

    override func viewDidLoad() {
        super.viewDidLoad()
                
        delegate = self
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor.black
        
        mapView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Home"), tag: 0)
        resourcesView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Resources"), tag: 1)
        calendarView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Calendar"), tag: 2)
        
        self.viewControllers = [mapView, resourcesView, calendarView]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if self.selectedViewController == mapView {
            if item.tag == 0 {
                
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(TabBarController.homePressedMessage), object: nil)
            }

        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
