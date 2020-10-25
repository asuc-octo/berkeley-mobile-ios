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

/// Contained view to be used in CollectionView and TableView cells for campus-wide events
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
        
        self.addSubview(nameLabel)
        self.addSubview(infoLabelsStack)
        self.addSubview(cellImage)
        
        nameLabel.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -10).isActive = true
        
        infoLabelsStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        infoLabelsStack.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        infoLabelsStack.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -10).isActive = true
        infoLabelsStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        
        cellImage.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        cellImage.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        cellImage.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        cellImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35).isActive = true
        
        
        infoLabelsStack.addArrangedSubview(timeLabel)
        timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        locationLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    /**
     Update the values in the cell based on a new event (when collection/table is scrolled)
     imageUpdate called to update cell image if cell is still visible
     */
    public func updateContents(event: EventCalendarEntry, cell: ImageViewCell) {
        nameLabel.text = event.name
        timeLabel.text = event.dateString
        
        if infoLabelsStack.arrangedSubviews.contains(locationLabel) {
            if let location = event.location {
                locationLabel.text = location
            } else {
                infoLabelsStack.removeArrangedSubview(locationLabel)
            }
        } else if let location = event.location {
            infoLabelsStack.addArrangedSubview(locationLabel)
            locationLabel.text = location
        }
        
        cell.updateImage(item: event)
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
    
    let infoLabelsStack: UIStackView = {
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
