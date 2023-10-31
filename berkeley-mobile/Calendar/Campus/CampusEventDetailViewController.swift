//
//  CampusEventDetailViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 9/19/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class CampusEventDetailViewController: UIViewController {
    var barView: BarView!
    var event: EventCalendarEntry!
    var overviewCard: EventOverviewCardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpBackgroundView()
        setUpScrollView()
        setUpOverviewCard()
        setupDescriptionCard()
        setUpButtons()
    }
    
    func setUpBackgroundView() {
        view.backgroundColor = BMColor.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        
        barView = BarView(superViewWidth: view.frame.width)
        view.addSubview(barView)
    }
    
    func setUpScrollView() {
        view.addSubview(scrollingStackView)
        scrollingStackView.setLayoutMargins(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        scrollingStackView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setUpOverviewCard() {
        overviewCard = EventOverviewCardView(event: event)
        overviewCard.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        scrollingStackView.stackView.addArrangedSubview(overviewCard)
    }
    
    func setupDescriptionCard() {
        guard let descriptionCard = DescriptionCardView(description: event.description) else { return }
        
        scrollingStackView.stackView.addArrangedSubview(descriptionCard)
    }
    
    func setUpButtons() {
        if event.sourceLink != nil {
            scrollingStackView.stackView.addArrangedSubview(learnMoreButton)
        }
        if event.registerLink != nil {
            scrollingStackView.stackView.addArrangedSubview(registerButton)
        }
        scrollingStackView.stackView.addArrangedSubview(addToCalendarButton)
    }
    
    @objc private func learnMoreTapped(sender: UIButton) {
        guard let url = event.sourceLink else { return }
        
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to open a web page with more info for this event.", website_url: url)
    }
    @objc private func registerTapped(sender: UIButton) {
        guard let url = event.registerLink else { return }
        
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to open the web page to register for this event.", website_url: url)
    }
    @objc private func addToCalendar(sender: UIButton) {
        event.addToDeviceCalendar(vc: self)
    }
    
    var learnMoreButton: ActionButton = {
        let button = ActionButton(title: "Learn More")
        button.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
        return button
    }()
    
    var registerButton: ActionButton = {
        let button = ActionButton(title: "Register")
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return button
    }()
    
    var addToCalendarButton: ActionButton = {
        let button = ActionButton(title: "Add To Calendar")
        button.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
        return button
    }()
    
    var scrollingStackView: ScrollingStackView = {
        let scrollingStackView = ScrollingStackView()
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        return scrollingStackView
    }()
}
