//
//  ResourceGroupSectionHeaderView.swift
//  berkeleyMobileiOS
//
//  Created by Kevin Bunarjo on 11/27/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

fileprivate let kColorBlue = UIColor(red: 50/255, green: 102/255, blue: 135/255, alpha: 1)

class ResourceGroupSectionHeaderView: UIView {
    let sectionLabel: UILabel = UILabel()
    let caretImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sectionLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold)
        sectionLabel.textColor = kColorBlue
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        caretImage.contentMode = .scaleAspectFit
        caretImage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sectionLabel)
        addSubview(caretImage)
        
        sectionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        sectionLabel.rightAnchor.constraint(equalTo: caretImage.leftAnchor, constant: -12).isActive = true
        sectionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        sectionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        caretImage.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        caretImage.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        caretImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        caretImage.widthAnchor.constraint(equalTo: caretImage.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
