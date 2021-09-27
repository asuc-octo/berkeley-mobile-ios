//
//  MainDrawerViewController.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

// Main drawer containing the library, dining, and fitness tabs; can't be dismissed
class MainDrawerViewController: DrawerViewController {
    
    var bottomOffset: CGFloat? {
        didSet {
            tabBarViewController.view.frame = self.view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bottomOffset! + 36, right: 0))
            tabBarViewController.view.frame.origin.y = barView.frame.maxY + 24
        }
    }
    // the view controller this is added onto
    var container: MainContainerViewController
    
    var tabBarViewController = SegmentedControlViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTabBar()
    }
    
    init(container: MainContainerViewController) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // set up the libraries, dining, and fitness tabs
    func setupTabBar() {
        tabBarViewController.pages = [
            Page(viewController: StudyViewController(), label: "Study"),
            Page(viewController: DiningViewController(), label: "Dining"),
            Page(viewController: FitnessViewController(), label: "Fitness")
        ]
        for page in tabBarViewController.pages {
            guard let vc = page.viewController as? SearchDrawerViewDelegate else { continue }
            vc.pinDelegate = container.mapViewController
        }
        // container.mapViewController
        self.add(child: tabBarViewController)
        tabBarViewController.view.frame = self.view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: (bottomOffset ?? 0) + 20, right: 0))
        tabBarViewController.view.frame.origin.y = barView.frame.maxY + 16
        tabBarViewController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        // set the containers for other views that can present drawers
        // currently, only dining and library views have detail views; add fitness view later
        for page in tabBarViewController.pages {
            if let dining = page.viewController as? DiningViewController {
                dining.mainContainer = container
            } else if let study = page.viewController as? StudyViewController {
                study.mainContainer = container
            } else if let gym = page.viewController as? FitnessViewController {
                gym.mainContainer = container
            }
        }
    }
    
}
