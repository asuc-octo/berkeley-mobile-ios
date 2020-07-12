//
//  FilterTableViewCell.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class FilterTableViewCell: UITableViewCell {
    
    static let kCellIdentifier = "filterCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup spacing between cells
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:5, left:5, bottom:5, right:5))
        backgroundView?.frame = contentView.frame
        selectedBackgroundView?.frame = contentView.frame
        
        // Setup corner radius and drop shadow
        backgroundColor = .clear
        backgroundView?.backgroundColor = Color.modalBackground
        
        backgroundView?.layer.masksToBounds = false
        backgroundView?.layer.cornerRadius = 7
        selectedBackgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 7
        
        backgroundView?.layer.shadowOpacity = 0.25
        backgroundView?.layer.shadowRadius = 5
        backgroundView?.layer.shadowOffset = .zero
        backgroundView?.layer.shadowColor = UIColor.black.cgColor
        backgroundView?.layer.shadowPath = UIBezierPath(rect: contentView.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundView = UIView()
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(cellImage)
        contentView.addSubview(recLabel)
        contentView.addSubview(distanceOccupancyStack)
        
        recLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        recLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        
        nameLabel.heightAnchor.constraint(equalToConstant: 65).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: recLabel.layoutMarginsGuide.bottomAnchor, constant: 5).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -10).isActive = true
        
        cellImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        cellImage.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        cellImage.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        cellImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.35).isActive = true
        
        distanceOccupancyStack.rightAnchor.constraint(lessThanOrEqualTo: cellImage.leftAnchor, constant: -10).isActive = true
        distanceOccupancyStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        distanceOccupancyStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -5).isActive = true
        distanceOccupancyStack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
    }
    
    // sets the contents of the cell based on an item passed in, the user's current location, and a closure to call if there is no image available
    func updateContents(item: SearchItem, location: CLLocation?, imageUpdate: () -> Void) {
        nameLabel.text = item.searchName
        distanceOccupancyStack.removeAllArrangedSubviews()
        if let itemWithLocation = item as? HasLocation, let userLocation = location {
            let distance = itemWithLocation.getDistanceToUser(userLoc: userLocation)
            if distance < type(of: itemWithLocation).invalidDistance {
                distLabel.text = "\(distance) mi"
                distanceOccupancyStack.addArrangedSubview(UIView.iconPairView(icon: distImage, iconHeight: 16, attachedView: distLabel))
            }
        }
        self.recLabel.text = "Recommended"
        
        if let itemWithOccupancy = item as? HasOccupancy, let status = itemWithOccupancy.getOccupancyStatus(date: Date()) {
            distanceOccupancyStack.addArrangedSubview(UIView.iconPairView(icon: chairImage, iconHeight: 16, iconWidth: 28, attachedView: status.badge()))
        }
        
        cellImage.image = UIImage(named: "DoeGlade")
        if let itemWithImage = item as? HasImage {
            if let itemImage = itemWithImage.image {
                cellImage.image = itemImage
            } else {
                imageUpdate()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = Font.bold(20)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        return label
    }()
    
    let cellImage:UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let recLabel:UILabel = {
        let label = UILabel()
        label.font = Font.mediumItalic(10)
        label.textColor = Color.darkGrayText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let distanceOccupancyStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        // arbitrary number that's large enough so that the left view is on the left edge and the right view is on the right edge
        // didn't set distribution to be .fill because that would stretch out the occupancy badge if only occupancy is available
        stack.spacing = 30
        return stack
    }()
    
    let distImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Walk")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let distLabel:UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chairImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Chair")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
}
