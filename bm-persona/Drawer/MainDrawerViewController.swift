//
//  MainDrawerViewController.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class MainDrawerViewController: DrawerViewController {
    
    var heightOffset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupBackgroundView()
        setupTabBar()
        setupGestures()
    }
    
    func setupTabBar() {
        let tabBarViewController = TabBarViewController()
        self.add(child: tabBarViewController)
        tabBarViewController.view.frame = self.view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: (heightOffset ?? 0) + 20, right: 0))
        tabBarViewController.view.frame.origin.y = barView.frame.maxY + 16
        tabBarViewController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}
