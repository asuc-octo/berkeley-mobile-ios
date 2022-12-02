//
//  SafetyResourceViewController.swift
//  berkeley-mobile
//
//  Created by Sydney Tsai on 11/18/22.
//  Copyright © 2022 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class SafetyResourceViewController: UIViewController {
    
    private var scrollingStack: ScrollingStackView!
    private var overviewStack: UIStackView!
    private var overviewCard: CardView!
    
    private var screeningUrl = "https://calcentral.berkeley.edu/"   // fallback url
    private var appointmentUrl = "https://uhs.berkeley.edu/medical/appointments"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        
        scrollingView()
        bearWalkOverview()
    }
}
    extension SafetyResourceViewController {
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
        
        func bearWalkOverview() {
            let card = CardView()
            card.layoutMargins = kCardPadding
            
            scrollingStack.stackView.addArrangedSubview(card)
            
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let headerLabel = UILabel()
            headerLabel.font = Font.bold(24)
            headerLabel.text = "Bear Walk"
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Visit website at: https://bearwalk.ridecell.com/request"
            subtitleLabel.font = Font.regular(16)
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
            
            let callToBookButton = ActionButton(title: "Call To Book", font: Font.regular(12))
//            callToBookButton.addTarget(self, action: #selector(appointmentButtonPressed), for: .touchUpInside)
            
            card.addSubview(callToBookButton)
            
            callToBookButton.translatesAutoresizingMaskIntoConstraints = false
            callToBookButton.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
            callToBookButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12).isActive = true
            
            card.bottomAnchor.constraint(equalTo: callToBookButton.bottomAnchor, constant: kViewMargin).isActive = true
            
            overviewCard = card
        }
        
        
}
