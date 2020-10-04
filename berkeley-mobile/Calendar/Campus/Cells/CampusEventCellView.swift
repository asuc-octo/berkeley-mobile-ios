//
//  CampusEventCellView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/3/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 10)
fileprivate let kViewMargin: CGFloat = 5

class CampusEventCellView: UIView {

    init(upcoming: Bool = false) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layoutMargins = kCardPadding
        
        if upcoming {
            timeLabel.textColor = Color.blueText
        } else {
            timeLabel.textColor = Color.blackText
        }
        
        self.addSubview(leftVerticalStack)
        self.addSubview(cellImage)
        
        leftVerticalStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        leftVerticalStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        leftVerticalStack.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -10).isActive = true
        leftVerticalStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        
        cellImage.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        cellImage.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        cellImage.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        cellImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35).isActive = true
        
        leftVerticalStack.addArrangedSubview(nameLabel)
        leftVerticalStack.addArrangedSubview(timeLabel)
        timeLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
    public func updateContents(event: EventCalendarEntry, imageUpdate: () -> Void) {
        nameLabel.text = event.name
        
        var dateString = ""
        if event.date.dateOnly() == Date().dateOnly() {
            dateString += "Today / "
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dateString += dateFormatter.string(from: event.date) + " / "
        }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        dateString += timeFormatter.string(from: event.date)
        timeLabel.text = dateString
        
        if leftVerticalStack.arrangedSubviews.contains(locationLabel) {
            if let location = event.location {
                locationLabel.text = location
            } else {
                leftVerticalStack.removeArrangedSubview(locationLabel)
            }
        } else if let location = event.location {
            leftVerticalStack.addArrangedSubview(locationLabel)
            locationLabel.text = location
        }
        
        cellImage.image = UIImage(named: "DoeGlade")
        if let image = event.image {
            cellImage.image = image
        } else {
            imageUpdate()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(20)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.numberOfLines = 0
        return label
    }()
    
    let leftVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = kViewMargin
        return stack
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
    
    let cellImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()

}
