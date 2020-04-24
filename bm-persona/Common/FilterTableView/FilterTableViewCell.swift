//
//  ResourceTableViewCell.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

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
        contentView.addSubview(personImage)
        contentView.addSubview(timeLabel)
        contentView.addSubview(chairImage)
        contentView.addSubview(capBadge)
        contentView.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: -5)
        
        recLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 10).isActive = true
        recLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        
        nameLabel.heightAnchor.constraint(equalToConstant: 65).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: recLabel.layoutMarginsGuide.bottomAnchor, constant: 5).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -10).isActive = true
        
        cellImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        cellImage.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        cellImage.widthAnchor.constraint(equalToConstant: contentView.frame.height * 2.5).isActive = true
        
        personImage.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        personImage.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        personImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        personImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        personImage.contentMode = .scaleAspectFit
        
        capBadge.centerYAnchor.constraint(equalTo: personImage.centerYAnchor).isActive = true
        capBadge.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -16).isActive = true
        capBadge.widthAnchor.constraint(equalToConstant: 50).isActive = true

        chairImage.centerYAnchor.constraint(equalTo: personImage.centerYAnchor).isActive = true
        chairImage.rightAnchor.constraint(equalTo: capBadge.leftAnchor, constant: -7).isActive = true
        chairImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        chairImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        chairImage.contentMode = .scaleAspectFit

        timeLabel.centerYAnchor.constraint(equalTo: personImage.centerYAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: personImage.rightAnchor, constant: 5).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: chairImage.leftAnchor, constant: -5).isActive = true
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
     
    let personImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Walk")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
     }()
     
    let timeLabel:UILabel = {
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
    
    let capBadge:TagView = {
        let cap = TagView(origin: .zero, text: "", color: .clear)
        cap.translatesAutoresizingMaskIntoConstraints = false
        return cap
    }()
    
    
}
