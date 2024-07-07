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
    
    let mapViewController = MapViewController()
    
    // MainDrawerViewDelegate properties
    var drawerStack: [DrawerViewDelegate] = []
    var positions: [DrawerState?] = []
    var mainDrawerPosition: DrawerState?
    
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
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
         // set the size of the main drawer to be equal to the size of the containing view
        drawerVC.view.frame = self.view.frame
        // necessary to move the center of the drawer later on
        drawerVC.view.translatesAutoresizingMaskIntoConstraints = true
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(homePressed), name: Notification.Name(TabBarController.homePressedMessage), object: nil)
    }
    
    @objc func homePressed() {
        if self.drawerStack.count > 0 {
            self.dismissTop()
        } else {
            self.moveCurrentDrawer(to: .collapsed)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        drawerStatePositions[.hidden] = self.view.frame.maxY + (self.view.frame.maxY / 2)
        // set the collapsed position to show the tab bar control at the top
        let tabBarVC = (drawerViewController as! MainDrawerViewController).tabBarViewController
        let offset = tabBarVC.control.frame.maxY + tabBarVC.view.frame.minY + 5
        drawerStatePositions[.collapsed] = self.view.frame.maxY * 1.45 - offset
        drawerStatePositions[.middle] = self.view.frame.midY * 1.1 + (self.view.frame.maxY / 2)
        drawerStatePositions[.full] = self.view.safeAreaInsets.top + (self.view.frame.maxY / 2)
        self.initialDrawerCenter = drawerViewController!.view.center
        moveDrawer(to: drawerViewController!.currState, duration: 0)
        attemptShowFeedbackForm()
    }
        
    override func viewSafeAreaInsetsDidChange() {
        (drawerViewController as! MainDrawerViewController).bottomOffset = self.view.safeAreaInsets.top
        DrawerViewController.bottomOffsetY = self.view.safeAreaInsets.top
    }
    
    
    private func attemptShowFeedbackForm() {
        let shownFeedbackForm = UserDefaults.standard.bool(forKey: UserDefaultKeys.hasShownFeedbackFrom)
        if !shownFeedbackForm {
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
}

extension MainContainerViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        handlePan(gesture: gesture)
    }
}
