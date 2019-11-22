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
        title.font = Font.bold(18)
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        
        badge = TagView(origin: .zero, text: "", color: .clear)
        contentView.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        badge.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
        
        subtitle = UILabel()
        subtitle.font = Font.thin(10)
        contentView.addSubview(subtitle)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.centerYAnchor.constraint(equalTo: badge.centerYAnchor).isActive = true
        subtitle.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        
        contentView.backgroundColor = Color.cellBackground
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
