//
//  CardTableViewCell.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/22/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup spacing between cells
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:5, left:5, bottom:5, right:5))
        backgroundView?.frame = contentView.frame
        selectedBackgroundView?.frame = contentView.frame
        
        // Setup corner radius and drop shadow
        backgroundColor = .clear
        backgroundView?.backgroundColor = BMColor.modalBackground
        
        backgroundView?.layer.masksToBounds = false
        backgroundView?.layer.cornerRadius = 12
        selectedBackgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12
        
        backgroundView?.layer.shadowOpacity = 0.25
        backgroundView?.layer.shadowRadius = 5
        backgroundView?.layer.shadowOffset = .zero
        backgroundView?.layer.shadowColor = UIColor.black.cgColor
        backgroundView?.layer.shadowPath = UIBezierPath(rect: contentView.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
