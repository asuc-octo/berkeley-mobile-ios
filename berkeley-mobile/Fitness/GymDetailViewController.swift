//
//  GymDetailViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 9/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class GymDetailViewController: SearchDrawerViewController {

    var gym: Gym!

    var overviewCard: OverviewCardView!
    var openTimesCard: OpenTimesCardView?
    var occupancyCard: OccupancyGraphCardView?
    var moreButton: ActionButton?
    var descriptionCard: DescriptionCardView?

    override var upperLimitState: DrawerState? {
        return openTimesCard == nil &&
               occupancyCard == nil &&
               moreButton == nil &&
               descriptionCard == nil ? .middle : nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScrollView()
        setUpOverviewCard()
        setUpOpenTimesCard()
        setUpOccupancyCard()
        setupMoreButton()
        setupDescriptionCard()
    }

    override func viewDidLayoutSubviews() {
        /* Set the bottom cutoff point for when the drawer appears
        The "middle" position for the view will show everything in the overview card
        When collapsible open time card is added, change this to show that card as well. */
        middleCutoffPosition = (openTimesCard?.frame.maxY ?? overviewCard.frame.maxY) + scrollingStackView.yOffset + 8
    }

    /// Opens `gym.website` in Safari. Called as a result of tapping on `moreButton`.
    @objc private func moreButtonClicked(sender: UIButton) {
        guard let url = gym.website else { return }
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?",
                            message: "Berkeley Mobile wants to open this fitness location's website",
                            options: "Cancel", "Yes",
                            website_url: url)
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
        openTimesCard = OpenTimesCardView(item: gym, animationView: scrollingStackView, toggleAction: { open in
            if open, self.currState != .full {
                self.delegate.moveDrawer(to: .full)
            }
        })
        guard let openTimesCard = self.openTimesCard else { return }
        scrollingStackView.stackView.addArrangedSubview(openTimesCard)
    }

    func setUpOccupancyCard() {
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
        view.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
}
