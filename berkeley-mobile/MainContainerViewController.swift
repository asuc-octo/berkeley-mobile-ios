//
//  MainContainerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import FactoryKit
import UIKit
import SwiftUI

class MainContainerViewController: UIViewController, MainDrawerViewDelegate {

    @Injected(\.homeViewModel) private var homeViewModel: HomeViewModel

    // MainDrawerViewDelegate properties
    var drawerStack: [DrawerViewDelegate] = []
    var positions: [DrawerState?] = []
    var mainDrawerPosition: DrawerState?
    
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState: CGFloat] = [:]
    
    private var homeViewController: UIViewController!
    private var homeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapVC = MapViewController()
        homeViewController = UIHostingController(rootView: HomeView(mapViewController: mapVC))
        homeView = homeViewController.view!
        homeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(homeView)
        
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: view.topAnchor),
            homeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension MainContainerViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        handlePan(gesture: gesture)
    }
}
