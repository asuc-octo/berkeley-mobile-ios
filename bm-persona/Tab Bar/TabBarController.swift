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
        
        let resourcesView = ResourcesViewController()
        resourcesView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Resources"), tag: 1)
        
        let calendarView = CalendarViewController()
        calendarView.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Calendar"), tag: 2)
        
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
