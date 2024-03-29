//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

fileprivate let kBookingURL = "https://berkeley.libcal.com"

class LibraryDetailViewController: SearchDrawerViewController {
    var library : Library!
    var overviewCard: OverviewCardView!
    var openTimesCard: OpenTimesCardView?
    var occupancyCard: OccupancyGraphCardView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        setUpOverviewCard()
        setUpOpenTimesCard()
        setUpBookButton()
        setupDescriptionCard()
    }
    
    override func viewDidLayoutSubviews() {
        /* Set the bottom cutoff point for when the drawer appears
        The "middle" position for the view will show everything in the overview card
        When collapsible open time card is added, change this to show that card as well. */
        middleCutoffPosition = (openTimesCard?.frame.maxY ?? overviewCard.frame.maxY) + scrollingStackView.yOffset + 8
    }

    /// Opens `kBookingURL` in Safari.
    @objc private func bookButtonClicked(sender: UIButton) {
        guard let url = URL(string: kBookingURL) else { return }
        
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to open Libcal to book a study room", website_url: url)
    }

    var scrollingStackView: ScrollingStackView = {
        let scrollingStackView = ScrollingStackView()
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        return scrollingStackView
    }()

    var bookButton: ActionButton = {
        let button = ActionButton(title: "Book a Study Room")
        button.addTarget(self, action: #selector(bookButtonClicked), for: .touchUpInside)
        return button
    }()
}

extension LibraryDetailViewController {
    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: library, excludedElements: [.openTimes, .occupancy])
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        scrollingStackView.stackView.addArrangedSubview(overviewCard)
    }
    
    func setUpOpenTimesCard() {
        guard library.weeklyHours != nil else { return }
        openTimesCard = OpenTimesCardView(item: library, animationView: scrollingStackView, toggleAction: { open in
            if open, self.currState != .full {
                self.delegate.moveDrawer(to: .full)
            }
        }, toggleCompletionAction: nil)
        guard let openTimesCard = self.openTimesCard else { return }
        scrollingStackView.stackView.addArrangedSubview(openTimesCard)
    }

    func setupDescriptionCard() {
        guard let descriptionCard = DescriptionCardView(description: library.description) else { return }
        scrollingStackView.stackView.addArrangedSubview(descriptionCard)
    }
    
    func setUpBookButton() {
        scrollingStackView.stackView.addArrangedSubview(bookButton)
    }
    
    func setUpScrollView() {
        scrollingStackView.scrollView.drawerViewController = self
        scrollingStackView.scrollView.setupDummyGesture()
        scrollingStackView.setLayoutMargins(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        view.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
}

// MARK: - Analytics

extension LibraryDetailViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_library", parameters: ["library" : library.name])
    }
}
