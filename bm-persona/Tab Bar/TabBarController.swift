//
//  TabBarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        tabBar.isTranslucent = false
        
        tabBar.tintColor = UIColor.black
        
        let mapView = MainContainerViewController()
        mapView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Home"), tag: 0)
        mapView.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        
        let resourcesView = UIViewController()
        resourcesView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Resources"), tag: 1)
        resourcesView.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        
        let calendarView = CalendarViewController()
        calendarView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Calendar"), tag: 2)
        calendarView.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        
        self.viewControllers = [mapView, resourcesView, calendarView]
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
