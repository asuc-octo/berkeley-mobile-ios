//
//  ResourceDetailViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 9/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

class CampusResourceDetailViewController: SearchDrawerViewController {

    var resource: Resource!

    var overviewCard: OverviewCardView!
    var openTimesCard: OpenTimesCardView?
    var descriptionCard: DescriptionCardView?

    override var upperLimitState: DrawerState? {
        return openTimesCard == nil &&
               descriptionCard == nil ? .middle : nil
    }

    /// Boolean indicating whether this view is presented modally or through a drawer.
    private var presentedModally: Bool = false

    init(presentedModally: Bool = false) {
        self.presentedModally = presentedModally
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScrollView()
        setUpOverviewCard()
        setUpOpenTimesCard()
        setupDescriptionCard()
    }

    override func setupGestures() {
        // No need to have gestures if this is not in a drawer.
        if presentedModally { return }
        super.setupGestures()
    }

    override func viewDidLayoutSubviews() {
        /* Set the bottom cutoff point for when the drawer appears
        The "middle" position for the view will show everything in the overview card
        When collapsible open time card is added, change this to show that card as well. */
        middleCutoffPosition = (openTimesCard?.frame.maxY ?? overviewCard.frame.maxY) + scrollingStackView.yOffset + 8
    }

    var scrollingStackView: ScrollingStackView = {
        let scrollingStackView = ScrollingStackView()
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        return scrollingStackView
    }()
}

// MARK: - View

extension CampusResourceDetailViewController {

    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: resource, excludedElements: [.openTimes])
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        scrollingStackView.stackView.addArrangedSubview(overviewCard)
    }

    func setUpOpenTimesCard() {
        guard resource.weeklyHours != nil else { return }
        openTimesCard = OpenTimesCardView(item: resource, animationView: scrollingStackView, toggleAction: { open in
            if open, self.currState != .full {
                self.delegate?.moveDrawer(to: .full)
            }
        })
        guard let openTimesCard = self.openTimesCard else { return }
        scrollingStackView.stackView.addArrangedSubview(openTimesCard)
    }

    func setupDescriptionCard() {
        descriptionCard = DescriptionCardView(description: resource.description)
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

// MARK: - Analytics

extension CampusResourceDetailViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_campus_resource", parameters: ["resource" : resource.name])
    }
}
