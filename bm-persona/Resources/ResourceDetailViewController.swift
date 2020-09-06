//
//  ResourceDetailViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 9/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class ResourceDetailViewController: SearchDrawerViewController {

    var resource: Resource!

    var overviewCard: OverviewCardView!
    var openTimesCard: OpenTimesCardView?

    override var upperLimitState: DrawerState? {
        return openTimesCard == nil ? .middle : nil
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

extension ResourceDetailViewController {

    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: resource, excludedElements: [.openTimes])
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        scrollingStackView.stackView.addArrangedSubview(overviewCard)
    }

    func setUpOpenTimesCard() {
        guard resource.weeklyHours != nil else { return }
        openTimesCard = OpenTimesCardView(item: resource, animationView: scrollingStackView, toggleAction: { open in
            if open, self.currState != .full {
                self.delegate.moveDrawer(to: .full, duration: 0.6)
            }
        })
        guard let openTimesCard = self.openTimesCard else { return }
        scrollingStackView.stackView.addArrangedSubview(openTimesCard)
    }

    func setUpScrollView() {
        view.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
}
