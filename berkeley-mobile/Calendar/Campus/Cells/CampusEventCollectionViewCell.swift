//
//  CampusEventCollectionViewCell.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/3/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class CampusEventCollectionViewCell: UICollectionViewCell, ImageViewCell {
    static let kCardSize: CGSize = CGSize(width: 223, height: 100)
    static let defaultImage = UIImage(named: "DoeGlade")
    static let kCellIdentifier = "campusEventCollection"
    
    var containedView: CampusEventCellView = CampusEventCellView(upcoming: true)
    
    var cellImageView: UIImageView {
        get {
            return containedView.cellImage
        }
    }
    
    var currentLoadUUID: UUID?
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancelImageOnReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = BMColor.cellBackground
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 7
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        contentView.addSubview(containedView)
        containedView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        containedView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        containedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateContents(event: EventCalendarEntry) {
        containedView.updateContents(event: event, cell: self)
    }
}
