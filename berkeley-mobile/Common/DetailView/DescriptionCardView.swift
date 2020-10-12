//
//  DescriptionCardView.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/3/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

/// A card with a label displaying the description for some resource.
class DescriptionCardView: CardView {

    /// A label for the bolded title of the card ("Description").
    private var cardTitle: UILabel!

    /// The label displaying the description.
    private var descriptionLabel: UILabel!

    public init?(description: String?) {
        guard let description = description else { return nil }
        super.init(frame: .zero)

        // Default padding for the card
        layoutMargins = kCardPadding

        cardTitle = UILabel()
        cardTitle.font = Font.bold(16)
        cardTitle.text = "Description"
        addSubview(cardTitle)

        cardTitle.translatesAutoresizingMaskIntoConstraints = false
        cardTitle.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        cardTitle.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
        cardTitle.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true

        descriptionLabel = UILabel()
        descriptionLabel.font = Font.regular(12)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = description
        addSubview(descriptionLabel)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: kViewMargin).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
