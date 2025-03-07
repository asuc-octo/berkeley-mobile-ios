//
//  GymDetailViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 9/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Firebase
import UIKit
import SwiftUI


// MARK: - GymDetailView

struct GymDetailView: UIViewControllerRepresentable {
    typealias UIViewControllerType = GymDetailViewController
    
    private let gym: Gym
    
    init(gym: Gym) {
        self.gym = gym
    }
    
    func makeUIViewController(context: Context) -> GymDetailViewController {
        let gymDetailVC = GymDetailViewController()
        gymDetailVC.gym = gym
        return gymDetailVC
    }
    
    func updateUIViewController(_ uiViewController: GymDetailViewController, context: Context) {}
}


// MARK: - GymDetailViewController

fileprivate let kViewMargin: CGFloat = 16

class GymDetailViewController: UIViewController {

    var gym: Gym!

    var overviewCard: OverviewCardView!
    var openTimesCard: OpenTimesCardView?
    var occupancyCard: OccupancyGraphCardView?
    var moreButton: ActionButton?
    var descriptionCard: DescriptionCardView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScrollView()
        setUpOverviewCard()
        setUpOpenTimesCard()
        setUpoccupancyCard()
        setupMoreButton()
        setupDescriptionCard()
    }

    /// Opens `gym.website` in Safari. Called as a result of tapping on `moreButton`.
    @objc private func moreButtonClicked(sender: UIButton) {
        guard let url = gym.website else { return }
        UIApplication.shared.open(url, options: [:])
    }

    var scrollingStackView: ScrollingStackView = {
        let scrollingStackView = ScrollingStackView()
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        return scrollingStackView
    }()
}

// MARK: - View

extension GymDetailViewController {

    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: gym, excludedElements: [.openTimes, .occupancy])
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        scrollingStackView.stackView.addArrangedSubview(overviewCard)
    }

    func setUpOpenTimesCard() {
        guard gym.weeklyHours != nil else { return }
        openTimesCard = OpenTimesCardView(item: gym, animationView: scrollingStackView, toggleAction: { _ in
        })
        guard let openTimesCard = self.openTimesCard else { return }
        scrollingStackView.stackView.addArrangedSubview(openTimesCard)
    }

    func setUpoccupancyCard() {
        guard let occupancy = gym.occupancy, let forDay = occupancy.occupancy(for: DayOfWeek.weekday(Date())), forDay.count > 0 else { return }
        occupancyCard = OccupancyGraphCardView(occupancy: occupancy, isOpen: gym.isOpen)
        guard let occupancyCard = self.occupancyCard else { return }
        scrollingStackView.stackView.addArrangedSubview(occupancyCard)
    }
    
    

    func setupMoreButton() {
        guard gym.website != nil else { return }
        let button = ActionButton(title: "Learn More")
        button.addTarget(self, action: #selector(moreButtonClicked), for: .touchUpInside)
        scrollingStackView.stackView.addArrangedSubview(button)
        moreButton = button
    }

    func setupDescriptionCard() {
        descriptionCard = DescriptionCardView(description: gym.description)
        guard let descriptionCard = descriptionCard else { return }
        scrollingStackView.stackView.addArrangedSubview(descriptionCard)
    }

    func setUpScrollView() {
        scrollingStackView.scrollView.setupDummyGesture()
        view.addSubview(scrollingStackView)
        scrollingStackView.setLayoutMargins(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        scrollingStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: kViewMargin).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - Analytics

extension GymDetailViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_gym", parameters: ["gym" : gym.name])
    }
}
