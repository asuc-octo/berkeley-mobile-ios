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
    private let feedbackFormViewModel = FeedbackFormViewModel()
    
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
        Task {
            let formConfig = await feedbackFormViewModel.fetchFeedbackFormConfig()
            attemptShowFeedbackForm(withConfig: formConfig)
        }
    }
    
    private func attemptShowFeedbackForm(withConfig formConfig: FeedbackFormConfig?) {
        guard let formConfig else {
            return
        }
    
        let numAppLaunchForFeedbackForm = UserDefaults.standard.integer(forKey: .numAppLaunchForFeedbackForm)
        
        if numAppLaunchForFeedbackForm >= formConfig.numToShow {
            let feedbackFormView = FeedbackFormView(config: formConfig)
            let hostingController = UIHostingController(rootView: feedbackFormView)
            hostingController.modalPresentationStyle = .fullScreen
            hostingController.modalTransitionStyle = .coverVertical
            present(hostingController, animated: true)
            UserDefaults.standard.set(0, forKey: .numAppLaunchForFeedbackForm)
        }
    }
}

extension MainContainerViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        handlePan(gesture: gesture)
    }
}
