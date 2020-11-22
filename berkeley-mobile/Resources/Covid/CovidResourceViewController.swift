//
//  CovidResourceViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 10/31/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class CovidResourceViewController: UIViewController {
    private var scrollingStack: ScrollingStackView!
    private var overviewStack: UIStackView!
    private var overviewCard: CardView!
    
    private var valueOne: UILabel!
    private var valueTwo: UILabel!
    private var lastUpdated: UILabel!
    
    private var screeningUrl = "https://calcentral.berkeley.edu/"   // fallback url
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        
        scrollingView()
        covidOverview()
        screeningCard()
        
        DataManager.shared.fetch(source: CovidResourceDataSource.self) { resourceEntries in
            guard let covidData = resourceEntries[0] as? CovidResource else { return }
                        
            self.screeningUrl = covidData.dailyScreeningLink
            self.valueOne.text = covidData.positivityRate
            self.valueTwo.text = covidData.totalCases
            self.lastUpdated.text = "Last Updated: \(covidData.lastUpdated)"
        }
    }
}

extension CovidResourceViewController {
    func scrollingView() {
        let scrollingStackView = ScrollingStackView()
        
        scrollingStackView.layoutMargins = kCardPadding
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        
        view.addSubview(scrollingStackView)
        
        scrollingStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: -8).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8).isActive = true
        
        scrollingStack = scrollingStackView
    }
    
    func covidOverview() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        
        scrollingStack.stackView.addArrangedSubview(card)
        
        card.translatesAutoresizingMaskIntoConstraints = false
//        card.topAnchor.constraint(equalTo: scrollingStack.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: scrollingStack.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: scrollingStack.layoutMarginsGuide.rightAnchor).isActive = true
        
        let headerLabel = UILabel()
        headerLabel.font = Font.bold(24)
        headerLabel.text = "Testing Dashboard"
        
        card.addSubview(headerLabel)
                
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 9
        
        let (uhsTests, uhsLabel) = createOverviewCard(cardHeader: "Positivity Rate", cardValue: 0)
        let (positiveTests, positiveLabel) = createOverviewCard(cardHeader: "Positive Tests", cardValue: 0)
        
        stack.addArrangedSubview(uhsTests)
        stack.addArrangedSubview(positiveTests)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: kViewMargin).isActive = true
        stack.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let updatedLabel = UILabel()
        updatedLabel.font = Font.light(14)
        updatedLabel.textColor = Color.lightGrayText
        updatedLabel.textAlignment = .left
        updatedLabel.text = "Last Updated: "
        
        card.addSubview(updatedLabel)
        
        updatedLabel.translatesAutoresizingMaskIntoConstraints = false
        updatedLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: kViewMargin).isActive = true
        updatedLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        updatedLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        card.bottomAnchor.constraint(equalTo: updatedLabel.bottomAnchor, constant: kViewMargin).isActive = true
        
        overviewStack = stack
        overviewCard = card
        
        valueOne = uhsLabel
        valueTwo = positiveLabel
        lastUpdated = updatedLabel
    }
    
    func createOverviewCard(cardHeader: String, cardValue: Int) -> (UIView, UILabel) {
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
        headerLabel.textAlignment = .center
        headerLabel.textColor = Color.selectedButtonBackground
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.7

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let valueLabel = UILabel()
        valueLabel.text = String(numberFormatter.string(from: NSNumber(value:cardValue)) ?? "N/A")
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
    
    func screeningCard() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        
        scrollingStack.stackView.addArrangedSubview(card)
        
        card.translatesAutoresizingMaskIntoConstraints = false
//        card.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: scrollingStack.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: scrollingStack.layoutMarginsGuide.rightAnchor).isActive = true
//        card.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor, constant: -kViewMargin).isActive = true
        
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
        subtitleLabel.text = "Complete the symptom screener before entering campus."
        subtitleLabel.font = Font.regular(12)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.7
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = Color.blackText
        
        let screenButton = ActionButton(title: "Start Daily Screening", font: Font.regular(12))
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
        
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to navigate to the Daily Symptom Screener", options: "Cancel", "Yes", website_url: url)
    }
}
