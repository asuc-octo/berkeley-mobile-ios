//
//  EventOverviewCardView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/24/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
fileprivate let kViewMargin: CGFloat = 10

class EventOverviewCardView: CardView {
    var event: CalendarEvent!
    
    public init(event: CalendarEvent) {
        super.init(frame: CGRect.zero)
        self.isUserInteractionEnabled = true
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        self.event = event
        
        setUpElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Setup
    func setUpElements() {
        self.addSubview(nameLabel)
        nameLabel.text = event.name
        nameLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        
        if let favoritableEvent = event as? CanFavorite {
            if favoritableEvent.isFavorited {
                faveButton.setImage(UIImage(named: "Gold Star"), for: .normal)
            } else {
                faveButton.setImage(UIImage(named: "Grey Star"), for: .normal)
            }
            self.addSubview(faveButton)
            faveButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
            faveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
            faveButton.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
            faveButton.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
            nameLabel.rightAnchor.constraint(equalTo: faveButton.leftAnchor, constant: -1 * kViewMargin).isActive = true
        }
        
        self.addSubview(detailsStack)
        detailsStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        detailsStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        detailsStack.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
        detailsStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        
        timeLabel.text = event.dateString
        let timeView = IconPairView(icon: clockIcon, iconHeight: 16, attachedView: timeLabel)
        detailsStack.addArrangedSubview(timeView)
        timeView.leftAnchor.constraint(equalTo: detailsStack.leftAnchor).isActive = true
        timeView.rightAnchor.constraint(equalTo: detailsStack.rightAnchor).isActive = true
        
        if let location = event.location {
            locationLabel.text = location
            let locationView = IconPairView(icon: locationIcon, iconHeight: 16, attachedView: locationLabel)
            detailsStack.addArrangedSubview(locationView)
            locationView.leftAnchor.constraint(equalTo: detailsStack.leftAnchor).isActive = true
            locationView.rightAnchor.constraint(equalTo: detailsStack.rightAnchor).isActive = true
        }
    }
    
    // MARK: - StackViews
    let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = kViewMargin
        return stack
    }()
    
    // MARK: - View Elements
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(24)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.numberOfLines = 0
        return label
    }()
    
    let clockIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Clock")?.colored(Color.blackText)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let locationIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Placemark")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.numberOfLines = 1
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.numberOfLines = 1
        return label
    }()
    
    let faveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    @objc func toggleFave(sender: UIButton) {
        if var favoritableItem = event as? CanFavorite {
            if favoritableItem.isFavorited {
                sender.setImage(UIImage(named: "Grey Star"), for: .normal)
                favoritableItem.isFavorited = false
            } else {
                sender.setImage(UIImage(named: "Gold Star"), for: .normal)
                favoritableItem.isFavorited = true
            }
        }
    }
}
