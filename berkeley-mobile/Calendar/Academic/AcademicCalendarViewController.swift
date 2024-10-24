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
    
    private var scrollingStackView: ScrollingStackView!
    private var calendarTablePair: CalendarTablePairView!
    
    private let eventScrapper = EventScrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Note: The top inset value will be also used as a vertical margin for `scrollingStackView`.
        self.view.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        
        setupScrollView()
        setUpCalendar()
        scrapeAcademicEvents()
    }

    private func scrapeAcademicEvents() {
        calendarTablePair.isLoading = true
        
        eventScrapper.delegate = self
        eventScrapper.scrape(at: EventScrapper.Constants.academicCalendarURLString)
    }
}

// MARK: - EventScrapperDelegate

extension AcademicCalendarViewController: EventScrapperDelegate {
    
    func eventScrapperDidFinishScrapping(results: [EventCalendarEntry]) {
        calendarTablePair.isLoading = false
        calendarTablePair.setCalendarEntries(entries: results)
    }
    
    func eventScrapperDidError(with errorDescription: String) {
        calendarTablePair.isLoading = false
        presentFailureAlert(title: "Unable To Parse Website", message: errorDescription)
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
    
    // MARK: Calendar
    private func setUpCalendar() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollingStackView.stackView.addArrangedSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        
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

