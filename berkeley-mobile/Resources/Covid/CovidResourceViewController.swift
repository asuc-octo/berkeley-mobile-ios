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
fileprivate let kScreeningUrl = "https://www.berkeley.edu"  // TODO: Change this!

class CovidResourceViewController: UIViewController {
    private var overviewStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        covidOverview()
        screeningCard()
    }
}

extension CovidResourceViewController {
    func covidOverview() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 9
        
        let uhsTests = createOverviewCard(cardHeader: "UHS Tests", cardValue: 4235)
        let positiveTests = createOverviewCard(cardHeader: "Positive Tests", cardValue: 6)
        
        stack.addArrangedSubview(uhsTests)
        stack.addArrangedSubview(positiveTests)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: kViewMargin * 3).isActive = true
        stack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        overviewStack = stack
    }
    
    func createOverviewCard(cardHeader: String, cardValue: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = Color.selectedButtonBackground.cgColor
                
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.alignment = .center
        cardStack.distribution = .fill
        cardStack.spacing = 24
        cardStack.layoutMargins = UIEdgeInsets(top: 19, left: 0, bottom: 19, right: 0)
        cardStack.isLayoutMarginsRelativeArrangement = true
        
        let headerLabel = UILabel()
        headerLabel.text = cardHeader
        headerLabel.font = Font.medium(24)
        headerLabel.textAlignment = .center
        headerLabel.textColor = Color.selectedButtonBackground
                
        let valueLabel = UILabel()
        valueLabel.text = String(cardValue)
        valueLabel.font = Font.bold(45)
        valueLabel.textAlignment = .center
        valueLabel.textColor = Color.selectedButtonBackground
        
        view.addSubview(cardStack)
        cardStack.addArrangedSubview(headerLabel)
        cardStack.addArrangedSubview(valueLabel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cardStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cardStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cardStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return view
    }
    
    func screeningCard() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: overviewStack.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
//        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -kViewMargin).isActive = true
        
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
        guard let url = URL(string: kScreeningUrl) else { return }
        
        presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to navigate to the Daily Symptom Screener", options: "Cancel", "Yes", website_url: url)
    }
}
