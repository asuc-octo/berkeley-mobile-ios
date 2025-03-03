//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Firebase
import UIKit
import SwiftUI

// MARK: - LibraryDetailView

struct LibraryDetailView: UIViewControllerRepresentable {
    typealias UIViewControllerType = LibraryDetailViewController
    
    private let library: Library
    
    init(library: Library) {
        self.library = library
    }
    
    func makeUIViewController(context: Context) -> LibraryDetailViewController {
        let libraryDetailVC = LibraryDetailViewController()
        libraryDetailVC.library = library
        return libraryDetailVC
    }
    
    func updateUIViewController(_ uiViewController: LibraryDetailViewController, context: Context) {}
}

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16
fileprivate let kBookingURL = "https://berkeley.libcal.com"

class LibraryDetailViewController: UIViewController {
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
        openTimesCard = OpenTimesCardView(item: library, animationView: scrollingStackView, toggleAction: { _ in }, toggleCompletionAction: nil)
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
        scrollingStackView.scrollView.setupDummyGesture()
        scrollingStackView.setLayoutMargins(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        view.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: kViewMargin).isActive = true
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
