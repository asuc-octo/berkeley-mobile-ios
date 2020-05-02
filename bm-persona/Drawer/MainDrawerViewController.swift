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
    var container: MainContainerViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupBackgroundView()
        setupTabBar()
        setupGestures()
    }
    
    init(container: MainContainerViewController) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTabBar() {
        let tabBarViewController = TabBarViewController()
        self.add(child: tabBarViewController)
        tabBarViewController.view.frame = self.view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: (heightOffset ?? 0) + 20, right: 0))
        tabBarViewController.view.frame.origin.y = barView.frame.maxY + 16
        tabBarViewController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        for page in tabBarViewController.pages {
            if let dining = page.viewController as? DiningViewController {
                dining.mainContainer = container
            } else if let library = page.viewController as? LibraryViewController {
                library.mainContainer = container
            }
        }
    }
    
}
