//
//  DiningLegendTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Kevin Bunarjo on 10/31/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class DiningLegendTableViewCell: UITableViewCell {
    let restrictionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let restrictionLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .lightGray
        
        addSubview(restrictionImage)
        addSubview(restrictionLabel)
        
        restrictionImage.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        restrictionImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        restrictionImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        restrictionImage.widthAnchor.constraint(equalTo: restrictionImage.heightAnchor).isActive = true
        
        restrictionLabel.leftAnchor.constraint(equalTo: restrictionImage.rightAnchor, constant: 12).isActive = true
        restrictionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        restrictionLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        restrictionLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
