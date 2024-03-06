//
//  CardCollectionViewCell.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/8/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    static let kCardSize: CGSize = CGSize(width: 223, height: 91)
    
    open var title: UILabel!
    open var subtitle: UILabel!
    open var badge: TagView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        title = UILabel()
        title.font = BMFont.bold(18)
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 2
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.7
        title.setContentHuggingPriority(.required, for: .vertical)
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
        
        badge = TagView(origin: .zero, text: "", color: .clear)
        contentView.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        badge.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
        
        subtitle = UILabel()
        subtitle.font = BMFont.light(12)
        subtitle.numberOfLines = 2
        subtitle.setContentHuggingPriority(.required, for: .vertical)
        subtitle.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addSubview(subtitle)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        subtitle.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        subtitle.rightAnchor.constraint(equalTo: badge.leftAnchor, constant: -5).isActive = true
        subtitle.topAnchor.constraint(greaterThanOrEqualTo: title.bottomAnchor).isActive = true
        let spacingConstraint = subtitle.topAnchor.constraint(greaterThanOrEqualTo: title.bottomAnchor, constant: 5)
        spacingConstraint.priority = .defaultHigh
        spacingConstraint.isActive = true
        
        contentView.backgroundColor = BMColor.cellBackground
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 7
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
