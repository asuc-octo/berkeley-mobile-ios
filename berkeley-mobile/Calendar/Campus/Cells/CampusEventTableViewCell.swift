//
//  CampusEventTableViewCell.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/3/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class CampusEventTableViewCell: UITableViewCell, ImageViewCell {
    
    static let kCellHeight: CGFloat = 160
    static let kCellIdentifier = "campusEventCell"
    static let defaultImage = UIImage(named: "DoeGlade")
    
    var containedView: CampusEventCellView = CampusEventCellView()
    var currentLoadUUID: UUID?
    var cellImageView: UIImageView {
        get {
            return containedView.cellImage
        }
    }
    
    func updateContents(event: EventCalendarEntry) {
        containedView.updateContents(event: event, cell: self)
    }
    
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
        contentView.addSubview(containedView)
        containedView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        containedView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        containedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
