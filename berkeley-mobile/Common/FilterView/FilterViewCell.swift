//
//  FilterViewCell.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class FilterViewCell: UICollectionViewCell {
    
    static let kCellSize: CGSize = CGSize(width: 32, height: 28)
    
    open var label: UILabel!

    override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        return CGSize(
            width: size.width + layoutMargins.left + layoutMargins.right,
            height: FilterViewCell.kCellSize.height
        )
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                contentView.backgroundColor = BMColor.selectedButtonBackground
                label.textColor = .white
            } else {
                contentView.backgroundColor = BMColor.cardBackground
                label.textColor = BMColor.secondaryText
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = bounds.height / 2
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        
        label = UILabel()
        label.font = BMFont.bold(14)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true

        isSelected = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
