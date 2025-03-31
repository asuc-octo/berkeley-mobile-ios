//
//  MainContainerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import SwiftUI

class MainContainerViewController: UIViewController, MainDrawerViewDelegate {
    
    // MainDrawerViewDelegate properties
    var drawerStack: [DrawerViewDelegate] = []
    var positions: [DrawerState?] = []
    var mainDrawerPosition: DrawerState?
    
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState: CGFloat] = [:]
    
    private let homeViewModel = HomeViewModel()
    private var homeViewController: UIViewController!
    private var homeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapVC = MapViewController()
        mapVC.homeViewModel = homeViewModel
        homeViewController = UIHostingController(rootView: HomeView(mapViewController: mapVC).environmentObject(homeViewModel))
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attemptShowFeedbackForm()
    }
    
    private func attemptShowFeedbackForm() {
        let numAppLaunchForFeedbackForm = UserDefaults.standard.integer(forKey: UserDefaultKeys.numAppLaunchForFeedbackForm)
        
        guard numAppLaunchForFeedbackForm == 1 else {
            if numAppLaunchForFeedbackForm == 0 {
                UserDefaults.standard.set(1, forKey: UserDefaultKeys.numAppLaunchForFeedbackForm)
            }
            return
        }
        
        let feedbackFormVC = UIViewController()
        feedbackFormVC.view.backgroundColor = .red
        
        let feedbackFormContentView = UIHostingController(rootView: FeedbackFormView())
        feedbackFormVC.addChild(feedbackFormContentView)
        feedbackFormVC.view.addSubview(feedbackFormContentView.view)

        feedbackFormContentView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            feedbackFormContentView.view.topAnchor.constraint(equalTo: feedbackFormVC.view.topAnchor),
            feedbackFormContentView.view.leadingAnchor.constraint(equalTo: feedbackFormVC.view.leadingAnchor),
            feedbackFormContentView.view.trailingAnchor.constraint(equalTo: feedbackFormVC.view.trailingAnchor),
            feedbackFormContentView.view.bottomAnchor.constraint(equalTo: feedbackFormVC.view.bottomAnchor)
        ])
        
        feedbackFormVC.modalPresentationStyle = .fullScreen
        feedbackFormVC.modalTransitionStyle = .coverVertical
        present(feedbackFormVC, animated: true)
    }
}

extension MainContainerViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        handlePan(gesture: gesture)
    }
}
