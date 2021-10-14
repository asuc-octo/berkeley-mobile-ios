//
//  DiningDetailViewController.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class DiningDetailViewController: SearchDrawerViewController {

    static let mealTimesChronological = ["breakfast": 0, "brunch": 1, "lunch": 2, "dinner": 3, "late night": 4, "other": 5]

    var diningHall: DiningLocation!
    var overviewCard: OverviewCardView!
    var segmentedControl: SegmentedControlViewController!

    override var upperLimitState: DrawerState? {
        get {
            return segmentedControl == nil ? .middle : nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpOverviewCard()
        setUpMenuControl()
        view.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        // set the bottom cutoff point for when drawer appears
        // the "middle" position for the view will show everything in the overview card
        middleCutoffPosition = overviewCard.frame.maxY + 8
    }
}

extension DiningDetailViewController {
    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: diningHall)
        view.addSubview(overviewCard)
        overviewCard.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        overviewCard.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.layoutSubviews()
    }

    func setUpMenuControl() {
        let meals = diningHall.meals
        guard meals.count > 0 else { return }

        /* Sort meal times chronologically using the mealTimesChronological dictionary
         Currently supports Breakfast, Brunch, Lunch, Dinner, Late Night*/
        let mealNames = Array(meals.keys).sorted(by: { (meal1, meal2) -> Bool in
            let m1Priority = DiningDetailViewController.mealTimesChronological[meal1.lowercased()] ??
                DiningDetailViewController.mealTimesChronological["other"]!
            let m2Priority = DiningDetailViewController.mealTimesChronological[meal2.lowercased()] ??
                DiningDetailViewController.mealTimesChronological["other"]!
            return m1Priority < m2Priority
        })

        segmentedControl = SegmentedControlViewController(pages: mealNames.compactMap {
            guard let menu = meals[$0] else { return nil }
            return Page(viewController: DiningMenuViewController(menu: menu, layoutMargins: view.layoutMargins), label: $0)
        })
        self.add(child: segmentedControl)
        segmentedControl.view.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.view.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        segmentedControl.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        segmentedControl.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        segmentedControl.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - Analytics

extension DiningDetailViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_food", parameters: ["dining_location" : diningHall.name])
    }
}
