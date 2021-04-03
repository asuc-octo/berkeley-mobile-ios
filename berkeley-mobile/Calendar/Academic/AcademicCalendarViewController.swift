//
//  AcademicCalendarViewController.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 9/22/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
fileprivate let kViewMargin: CGFloat = 6

/// Displays the 'Academic' events in the Calendar tab.
class AcademicCalendarViewController: UIViewController {
    /// Categories to include from all events
    private static let categories = ["Academic Calendar"]
    
    private var scrollingStackView: ScrollingStackView!
    private var calendarTablePair: CalendarTablePairView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Note: The top inset value will be also used as a vertical margin for `scrollingStackView`.
        self.view.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        
        setupScrollView()
        setUpCalendar()
        
        DataManager.shared.fetch(source: EventDataSource.self) { calendarEntries in
            let entries = (calendarEntries as? [EventCalendarEntry])?.filter({ entry -> Bool in
                return AcademicCalendarViewController.categories.contains(entry.category)
            }) ?? []
            self.calendarTablePair.calendarEntries = entries.sorted(by: {
                $0.date.compare($1.date) == .orderedAscending
            })
        }
    }
}

// MARK: - View

extension AcademicCalendarViewController {
    
    private func setupScrollView() {
        scrollingStackView = ScrollingStackView()
        scrollingStackView.setLayoutMargins(view.layoutMargins)
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        view.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: Calendar Table
    
    private func setUpCalendar() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollingStackView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor).isActive = true
        
        calendarTablePair = CalendarTablePairView(parentVC: self)
        card.addSubview(calendarTablePair)
        calendarTablePair.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        calendarTablePair.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        calendarTablePair.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        calendarTablePair.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
    }
}

extension AcademicCalendarViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_academic_calendar", parameters: nil)
    }
}

