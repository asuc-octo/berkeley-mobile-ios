//
//  CovidResourceViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 3/8/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

class CovidResourceViewController: UIViewController {
    private var scrollingStack: ScrollingStackView!
    private var overviewStack: UIStackView!
    private var overviewCard: CardView!
    
    private var valueOne: UILabel!
    private var valueTwo: UILabel!
    private var lastUpdated: UILabel!
    
    private var screeningUrl = "https://calcentral.berkeley.edu/"   // fallback url
    private var appointmentUrl = "https://uhs.berkeley.edu/medical/appointments"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        
        scrollingView()
        scrollingStack.stackView.addArrangedSubview(BearWalkCard())
        scrollingStack.stackView.addArrangedSubview(RecentAlertsTableViewController())
//        scrollingStack.stackView.addArrangedSubview(RecentAlertsTableViewController().view)
//        appointmentCard()
//        screeningCard()
    }
}

extension CovidResourceViewController {
    func scrollingView() {
        let scrollingStackView = ScrollingStackView()

        scrollingStackView.setLayoutMargins(kCardPadding)
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        
        view.addSubview(scrollingStackView)
        
        scrollingStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: -8).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8).isActive = true
        
        scrollingStack = scrollingStackView
    }
    
    func createOverviewCard(cardHeader: String, cardValue: Int? = nil) -> (UIView, UILabel) {
        let subView = UIView()
        subView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        subView.layer.cornerRadius = 12
        subView.layer.masksToBounds = true
        subView.layer.borderWidth = 3
        subView.layer.borderColor = Color.selectedButtonBackground.cgColor
                
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.alignment = .center
        cardStack.distribution = .fill
        cardStack.spacing = 15
        cardStack.layoutMargins = UIEdgeInsets(top: 19, left: 19, bottom: 19, right: 19)
        cardStack.isLayoutMarginsRelativeArrangement = true
        
        let headerLabel = UILabel()
        headerLabel.text = cardHeader
        headerLabel.font = Font.medium(20)
        headerLabel.textAlignment = .center
        headerLabel.textColor = Color.selectedButtonBackground
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.7

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let valueLabel = UILabel()
        if let value = cardValue {
            valueLabel.text = String(numberFormatter.string(from: NSNumber(value: value)) ?? "N/A")
        } else {
            valueLabel.text = "N/A"
        }
        valueLabel.font = Font.bold(40)
        valueLabel.textAlignment = .center
        valueLabel.textColor = Color.selectedButtonBackground
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
        
        subView.addSubview(cardStack)
        cardStack.addArrangedSubview(headerLabel)
        cardStack.addArrangedSubview(valueLabel)
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardStack.topAnchor.constraint(equalTo: subView.topAnchor).isActive = true
        cardStack.leftAnchor.constraint(equalTo: subView.leftAnchor).isActive = true
        cardStack.rightAnchor.constraint(equalTo: subView.rightAnchor).isActive = true
        cardStack.bottomAnchor.constraint(equalTo: subView.bottomAnchor).isActive = true
        
        return (subView, valueLabel)
    }
    
    func appointmentCard() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        
        scrollingStack.stackView.addArrangedSubview(card)
        
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let headerLabel = UILabel()
        headerLabel.text = "Need an appointment?"
        headerLabel.font = Font.bold(24)
        headerLabel.textAlignment = .left
        headerLabel.textColor = Color.blackText
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.7
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Book an appointment through University Health Services:"
        subtitleLabel.font = Font.regular(12)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.7
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = Color.blackText
        
        card.addSubview(headerLabel)
        card.addSubview(subtitleLabel)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let appointmentButton = UIButton()
        appointmentButton.setTitle("Book Now", for: .normal)
        appointmentButton.backgroundColor = Color.lowOccupancyTag
        appointmentButton.layer.cornerRadius = 15
        appointmentButton.layer.masksToBounds = true
        appointmentButton.titleLabel?.font = Font.medium(16)
        appointmentButton.addTarget(self, action: #selector(appointmentButtonPressed), for: .touchUpInside)
        
        card.addSubview(appointmentButton)
        
        appointmentButton.translatesAutoresizingMaskIntoConstraints = false
        appointmentButton.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        appointmentButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12).isActive = true
        
        appointmentButton.setHeightConstraint(33)
        appointmentButton.setWidthConstraint(110)
        
        card.bottomAnchor.constraint(equalTo: appointmentButton.bottomAnchor, constant: 16).isActive = true
    }
    
    func screeningCard() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        
        scrollingStack.stackView.addArrangedSubview(card)
        
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 14
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: kViewMargin, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        
        let image = UIImage(named: "CovidScreening")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        
        let bear = UIImage(named: "CovidBear")
        let bearView = UIImageView(image: bear)
        bearView.contentMode = .scaleAspectFill
        
        let onCampusLabel = UILabel()
        onCampusLabel.text = "Will you be on campus today?"
        onCampusLabel.font = Font.bold(22)
        onCampusLabel.numberOfLines = 1
        onCampusLabel.adjustsFontSizeToFitWidth = true
        onCampusLabel.minimumScaleFactor = 0.7
        onCampusLabel.textAlignment = .center
        onCampusLabel.textColor = Color.blackText
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Complete the health survey before entering campus."
        subtitleLabel.font = Font.regular(12)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.7
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = Color.blackText
        
        let screenButton = ActionButton(title: "Start Health Survey", font: Font.regular(12))
        screenButton.addTarget(self, action: #selector(screeningButtonPressed), for: .touchUpInside)
        
        card.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(bearView)
        stack.addArrangedSubview(onCampusLabel)
        stack.addArrangedSubview(subtitleLabel)
        stack.addArrangedSubview(screenButton)
        
        // Resolve smaller screens
        stack.bringSubviewToFront(onCampusLabel)
        stack.bringSubviewToFront(subtitleLabel)
        stack.bringSubviewToFront(screenButton)
        
        stack.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
        
        imageView.setHeightConstraint(101)
        imageView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        
        stack.setCustomSpacing(-65, after: imageView)  // Bless whoever created this
        
        bearView.setHeightConstraint(130)
        bearView.setWidthConstraint(130)
        
        stack.setCustomSpacing(-5, after: bearView)
        
        screenButton.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        screenButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
    }
    
    @objc private func screeningButtonPressed(sender: UIButton) {
        guard let url = URL(string: screeningUrl) else { return }
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to navigate to the Health Survey", website_url: url)
    }
    
    @objc private func appointmentButtonPressed(sender: UIButton) {
        guard let url = URL(string: appointmentUrl) else { return }
        
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to navigate to the UHS Booking Website", website_url: url)
    }
}


// MARK: - Analytics
extension CovidResourceViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_covid_resource", parameters: [:])
    }
}
