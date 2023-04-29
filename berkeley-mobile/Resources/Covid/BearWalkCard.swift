//
//  BearWalkCard.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/17/23.
//  Copyright © 2023 ASUC OCTO. All rights reserved.
//

import UIKit
import SafariServices

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

class BearWalkCard: CardView {
    private let bookOnWebsiteURL = "https://bearwalk.ridecell.com/request"
    private let bearWalkPhoneNumber = "5106429255"
    
    init() {
        super.init(frame: .zero)
        configureBearWalkCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBearWalkCard() {
        self.layoutMargins = kCardPadding
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let headerLabel = UILabel()
        headerLabel.text = "Bear Walk"
        headerLabel.font = Font.bold(24)
        headerLabel.textAlignment = .left
        headerLabel.textColor = Color.blackText
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.7
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "BearWalk is a walking escort provided by the University Police (UCPD) \nHours of Operation: Everyday Dusk-3:00am"
        subtitleLabel.font = Font.regular(18)
        subtitleLabel.numberOfLines = 3
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.7
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = Color.blackText
        
        let downloadAppLabel = UILabel()
        downloadAppLabel.text = "Download App >"
        downloadAppLabel.textAlignment = .right
        downloadAppLabel.textColor = Color.darkGrayText
        downloadAppLabel.numberOfLines = 1
        downloadAppLabel.adjustsFontSizeToFitWidth = true
        downloadAppLabel.font = Font.regular(20)
        downloadAppLabel.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(goToBearWalkAppInAppStore))
        downloadAppLabel.addGestureRecognizer(tapAction)
        
        //Buttons
        let buttonHorizontalStack = UIStackView()
        buttonHorizontalStack.axis = .horizontal
        buttonHorizontalStack.alignment = .center
        buttonHorizontalStack.distribution = .fillEqually
        buttonHorizontalStack.spacing = 15
        buttonHorizontalStack.layoutMargins = UIEdgeInsets(top: 19, left: 19, bottom: 19, right: 19)
        buttonHorizontalStack.isLayoutMarginsRelativeArrangement = true
        
        let callToBookButton = UIButton()
        callToBookButton.setTitle("Call to book", for: .normal)
        callToBookButton.backgroundColor = Color.highOccupancyTag.withAlphaComponent(0.7)
        callToBookButton.layer.cornerRadius = 15
        callToBookButton.layer.masksToBounds = true
        callToBookButton.titleLabel?.font = Font.medium(16)
        callToBookButton.addTarget(self, action: #selector(callToBookPressed), for: .touchUpInside)
        
        let bookOnWebsiteButton = UIButton()
        bookOnWebsiteButton.setTitle("Book on Website", for: .normal)
        bookOnWebsiteButton.backgroundColor = Color.highOccupancyTag.withAlphaComponent(0.7)
        bookOnWebsiteButton.layer.cornerRadius = 15
        bookOnWebsiteButton.layer.masksToBounds = true
        bookOnWebsiteButton.titleLabel?.font = Font.medium(16)
        bookOnWebsiteButton.addTarget(self, action: #selector(bookOnWebsitePressed), for: .touchUpInside)
        
        buttonHorizontalStack.addArrangedSubview(callToBookButton)
        buttonHorizontalStack.addArrangedSubview(bookOnWebsiteButton)
        
        self.addSubview(downloadAppLabel)
        self.addSubview(headerLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(buttonHorizontalStack)
        
        downloadAppLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo:
                    self.layoutMarginsGuide.topAnchor),
            headerLabel.leftAnchor.constraint(equalTo:
                    self.layoutMarginsGuide.leftAnchor),
            headerLabel.rightAnchor.constraint(equalTo:
                    self.layoutMarginsGuide.rightAnchor),
            
            downloadAppLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            downloadAppLabel.trailingAnchor.constraint(equalTo:
                    self.layoutMarginsGuide.trailingAnchor, constant: -10),
            downloadAppLabel.heightAnchor.constraint(equalToConstant: 40),
            downloadAppLabel.widthAnchor.constraint(equalToConstant: 90),
            
            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            subtitleLabel.leftAnchor.constraint(equalTo:
                    self.layoutMarginsGuide.leftAnchor),
            subtitleLabel.rightAnchor.constraint(equalTo:
                    self.layoutMarginsGuide.rightAnchor),
            
            buttonHorizontalStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            buttonHorizontalStack.leadingAnchor.constraint(equalTo:
                    self.leadingAnchor),
            buttonHorizontalStack.trailingAnchor.constraint(equalTo:
                    self.trailingAnchor),
            buttonHorizontalStack.bottomAnchor.constraint(equalTo:
                    self.bottomAnchor),
            
            callToBookButton.heightAnchor.constraint(equalToConstant: 33),
            callToBookButton.widthAnchor.constraint(equalToConstant: 110),
            
            bookOnWebsiteButton.heightAnchor.constraint(equalToConstant: 33),
            bookOnWebsiteButton.widthAnchor.constraint(equalToConstant: 110)
        ])
    }

    
    
    @objc private func bookOnWebsitePressed() {
        //present Safari ViewController
        guard let url = URL(string: bookOnWebsiteURL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .pageSheet
        
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
             topVC = topVC!.presentedViewController
        }
        topVC?.present(safariVC, animated: true)
    }
    
    @objc private func goToBearWalkAppInAppStore() {
        if let url = URL(string: "https://apps.apple.com/us/app/ucb-bearwalk/id426315434") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func callToBookPressed() {
        guard let url = URL(string: "tel://\(bearWalkPhoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
}
