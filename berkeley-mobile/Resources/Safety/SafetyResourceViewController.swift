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
    
    private var bookUrl = "https://www.bearwalk.ridecell.com"
    
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
            
            
            let subtitleLabel = UITextView()
            
            let attributedString = NSMutableAttributedString(string: "Visit website at: ")
            let url = URL(string: "http://www.bearwalk.ridecell.com/request")!
            attributedString.setAttributes([.link: url], range: NSMakeRange(5, 10))
            
            subtitleLabel.text = Text(attributedString + url)

            subtitleLabel.attributedText = attributedString
            subtitleLabel.isUserInteractionEnabled = true
            subtitleLabel.isEditable = false

            subtitleLabel.linkTextAttributes = [
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]

            let string = "bearwalk.ridecell.com/request"
            let attributedLinkString = NSMutableAttributedString(string: string, attributes:[NSAttributedString.Key.link: URL(string: "http://www.bearwalk.ridecell.com/request")!])
            
            
            subtitleLabel.text = "Visit website at: " + string
            subtitleLabel.font = Font.regular(16)
            subtitleLabel.numberOfLines = 1
            subtitleLabel.adjustsFontSizeToFitWidth = true
            subtitleLabel.minimumScaleFactor = 0.7
            subtitleLabel.textAlignment = .left
            subtitleLabel.textColor = Color.blackText
            
            let headerEndLabel = UILabel()
            headerEndLabel.text = "Download App >"
            headerEndLabel.font = Font.regular(12)
            headerEndLabel.textAlignment = .right
            headerEndLabel.textColor = Color.lightLightGrayText
            
            card.addSubview(headerLabel)
            card.addSubview(subtitleLabel)
            card.addSubview(headerEndLabel)
                    
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
            headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
            headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
            
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12).isActive = true
            subtitleLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
            subtitleLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
            
            headerEndLabel.translatesAutoresizingMaskIntoConstraints = false
            headerEndLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
            headerEndLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
            
            
            let callToBookButton = ActionButton(title: "Call To Book", font: Font.regular(12), defaultColor: UIColor(red: 0.887, green: 0.447, blue: 0.447, alpha: 1))
            callToBookButton.addTarget(self, action: #selector(bookButtonPressed), for: .touchUpInside)
            
            card.addSubview(callToBookButton)
            
            callToBookButton.translatesAutoresizingMaskIntoConstraints = false
            callToBookButton.centerXAnchor.constraint(equalTo: card.layoutMarginsGuide.centerXAnchor).isActive = true
            callToBookButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12).isActive = true
            callToBookButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
            callToBookButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            card.bottomAnchor.constraint(equalTo: callToBookButton.bottomAnchor, constant: kViewMargin).isActive = true
            
            overviewCard = card
            
        }
       
        @objc private func bookButtonPressed(sender: UIButton) {
            guard let url = URL(string: bookUrl) else { return }
            
            presentAlertLinkUrl(title: "Are you sure you want to open Safari?", message: "Berkeley Mobile wants to navigate to the Bearwalk Ridecell Website", website_url: url)
        }
}
