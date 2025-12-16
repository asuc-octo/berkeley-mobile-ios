//
//  TabBarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import SwiftUI

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let mapView = MainContainerViewController()
    private let calendarView = UIHostingController(rootView: EventsView())
    private let safetyView = UIHostingController(rootView: SafetyView())
    private let resourcesView = UIHostingController(rootView: ResourcesView())
    
    private let feedbackFormPresenter = FeedbackFormPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
        feedbackFormPresenter.delegate = self
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return
        }
        
        #if DEBUG
        let debugViewModel = DebugViewModel(feedbackFormPresenter: feedbackFormPresenter)
        let debugView = UIHostingController(rootView: DebugView(debugViewModel: debugViewModel))
        present(debugView, animated: true)
        #endif
    }
    
    public func selectMainTab() {
        if let mainIndex = self.viewControllers?.firstIndex(of: mapView) {
            self.selectedIndex = mainIndex
        }
    }
    
    private func setupTabbar() {
        delegate = self
        tabBar.isTranslucent = false
        tabBar.tintColor = BMColor.blackText
        
        let tabBarAppearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: BMFont.regular(11)]
        tabBarAppearance.setTitleTextAttributes(attributes, for: .normal)
        tabBar.tintColor = UIColor.label
        tabBar.isTranslucent = true
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = BMColor.cardBackground

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        
        mapView.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        calendarView.tabBarItem = UITabBarItem(title: "Events", image: UIImage(systemName: "calendar"), tag: 1)
        safetyView.tabBarItem = UITabBarItem(title: "Safety", image: UIImage(systemName: "exclamationmark.shield"), tag: 2)
        resourcesView.tabBarItem = UITabBarItem(title: "Resources", image: UIImage(systemName: "tray.full"), tag: 3)
        
        self.viewControllers = [mapView, calendarView, safetyView, resourcesView]
    }
}


// MARK: - FeedbackFormPresenterDelegate

extension TabBarController: FeedbackFormPresenterDelegate {
    func presentFeedbackForm(withViewController viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true)
    }
}
