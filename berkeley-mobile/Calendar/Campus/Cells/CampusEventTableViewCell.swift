//
//  CampusEventTableViewCell.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/3/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class CampusEventTableViewCell: CardTableViewCell, ImageViewCell {
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
