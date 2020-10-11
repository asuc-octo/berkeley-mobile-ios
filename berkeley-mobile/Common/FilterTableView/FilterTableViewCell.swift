//
//  FilterTableViewCell.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class FilterTableViewCell: UITableViewCell, ImageViewCell {
    
    static let kCellIdentifier = "filterCell"
    static let defaultImage = UIImage(named: "DoeGlade")
    var currentLoadUUID: UUID?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancelImageOnReuse()
    }
    
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
        contentView.addSubview(cellImageView)
        contentView.addSubview(recLabel)
        contentView.addSubview(locationOccupancyView)
        
        recLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        recLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true

        nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: recLabel.layoutMarginsGuide.bottomAnchor, constant: 5).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: cellImageView.leftAnchor, constant: -10).isActive = true
        
        cellImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        cellImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        cellImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        cellImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.35).isActive = true
        
        locationOccupancyView.rightAnchor.constraint(equalTo: cellImageView.leftAnchor, constant: -10).isActive = true
        locationOccupancyView.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        locationOccupancyView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -5).isActive = true
        locationOccupancyView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
    }
    
    // Sets the contents of the cell based on an item passed in
    func updateContents(item: SearchItem) {
        locationOccupancyView.subviews.forEach({ $0.removeFromSuperview() })
        
        nameLabel.text = item.searchName
        var locationDetailVisible = false
        if let itemWithLocation = item as? HasLocation {
            locationDetailVisible = true
            locationDetailView.delegate = self
            locationDetailView.configure(for: itemWithLocation)
            locationOccupancyView.addSubview(locationDetailView)
            locationDetailView.rightAnchor.constraint(lessThanOrEqualTo: locationOccupancyView.rightAnchor).isActive = true
            locationDetailView.topAnchor.constraint(equalTo: locationOccupancyView.topAnchor).isActive = true
            locationDetailView.bottomAnchor.constraint(equalTo: locationOccupancyView.bottomAnchor).isActive = true
            locationDetailView.leftAnchor.constraint(equalTo: locationOccupancyView.leftAnchor).isActive = true
        }
        self.recLabel.text = "Recommended"
        self.recLabel.isHidden = true
        
        if let itemWithOccupancy = item as? HasOccupancy, let status = itemWithOccupancy.getCurrentOccupancyStatus(isOpen: (item as? HasOpenTimes)?.isOpen) {
            let occupancyView = IconPairView(icon: chairImage, iconHeight: 16, iconWidth: 28, attachedView: status.badge())
            locationOccupancyView.addSubview(occupancyView)
            occupancyView.topAnchor.constraint(equalTo: locationOccupancyView.topAnchor).isActive = true
            occupancyView.bottomAnchor.constraint(equalTo: locationOccupancyView.bottomAnchor).isActive = true
            if locationDetailVisible {
                occupancyView.rightAnchor.constraint(equalTo: locationOccupancyView.rightAnchor).isActive = true
                occupancyView.leftAnchor.constraint(greaterThanOrEqualTo: locationDetailView.rightAnchor, constant: 5).isActive = true
            } else {
                occupancyView.rightAnchor.constraint(lessThanOrEqualTo: locationOccupancyView.rightAnchor).isActive = true
                occupancyView.leftAnchor.constraint(equalTo: locationOccupancyView.leftAnchor).isActive = true
            }
        }
        
        if let itemWithImage = item as? HasImage {
            updateImage(item: itemWithImage)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(20)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.numberOfLines = 2
        return label
    }()
    
    let cellImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let recLabel: UILabel = {
        let label = UILabel()
        label.font = Font.mediumItalic(10)
        label.textColor = Color.darkGrayText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationDetailView: LocationDetailView = {
        return LocationDetailView()
    }()
    
    let locationOccupancyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

// MARK: - DetailViewDelegate

extension FilterTableViewCell: DetailViewDelegate {
    func detailsUpdated(for view: UIView) {
        if let locationDetailView = view as? LocationDetailView {
            locationDetailView.isHidden = locationDetailView.missingData
        }
    }
}
