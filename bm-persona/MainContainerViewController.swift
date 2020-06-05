//
//  MainContainerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class MainContainerViewController: UIViewController, MainDrawerViewDelegate {
    
    var positions: [DrawerState?] = []
    var mainDrawerPosition: DrawerState?
    
    let mapViewController = MapViewController()
    
    var drawerViewController: DrawerViewController?
    var drawerStack: [DrawerViewDelegate] = []
    var initialDrawerCenter = CGPoint()
    var drawerStatePositions: [DrawerState: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let drawerVC = MainDrawerViewController(container: self)
        drawerViewController = drawerVC
        add(child: mapViewController)
        add(child: drawerVC)
        drawerVC.delegate = self
        mapViewController.view.frame = self.view.frame
        mapViewController.mainContainer = self
        drawerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawerVC.view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            drawerVC.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            drawerVC.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            drawerVC.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 2 * self.view.frame.maxY)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawerStatePositions[.hidden] = self.view.frame.maxY + (self.view.frame.maxY / 2)
        drawerStatePositions[.collapsed] = self.view.frame.maxY * 0.9 + (self.view.frame.maxY / 2)
        drawerStatePositions[.middle] = self.view.frame.midY * 1.1 + (self.view.frame.maxY / 2)
        drawerStatePositions[.full] = self.view.safeAreaInsets.top + (self.view.frame.maxY / 2)
        (drawerViewController as! MainDrawerViewController).heightOffset = self.view.safeAreaInsets.top
        self.view.layoutSubviews()
        self.initialDrawerCenter = drawerViewController!.view.center
        moveDrawer(to: drawerViewController!.currState, duration: 0)
    }

}

// for main drawer view
extension MainContainerViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        handlePan(gesture: gesture)
    }
}
