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

        // Do any additional setup after loading the view.
        let mapView = MainContainerViewController()
        mapView.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        let calendarView = CalendarViewController()
        calendarView.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        self.viewControllers = [mapView, calendarView]
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
