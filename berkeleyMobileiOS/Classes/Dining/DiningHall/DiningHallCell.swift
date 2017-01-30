//
//  DiningHallCell.swift
//  berkeleyMobileiOS
//
//  Created by Bohui Moon on 10/14/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

fileprivate let kCellMargin: CGFloat = 16.0

fileprivate let kColorRed = UIColor.red
fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)

fileprivate let kLabelFont = "Helvetica Neue"
fileprivate let kFontSize13: CGFloat = 13.0
fileprivate let kFontSize16: CGFloat = 16.0
fileprivate let kLabelMargin: CGFloat = 4.0


/**
 * TableViewCell for DiningHall
 */
class DiningHallCell: UITableViewCell
{
    static let height: CGFloat = 72.0

    let nameLabel: UILabel = UILabel(frame: CGRect.zero)
    let statusLabel: UILabel = UILabel(frame: CGRect.zero)
    let divier: UIView = UIView(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.autoresizingMask = .flexibleWidth
        
        // Name label
        self.nameLabel.textColor = kColorNavy
        self.nameLabel.font = UIFont.systemFont(ofSize: kFontSize16)
        self.nameLabel.autoresizingMask = .flexibleWidth
        self.addSubview(self.nameLabel)
        
        // Status label
        self.statusLabel.autoresizingMask = .flexibleWidth
        self.addSubview(self.statusLabel)
        
        // Divider
        self.divier.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.divier.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.addSubview(self.divier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /* Layout labels according to the current size. */
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let size: CGSize = self.bounds.size
        
        var nameFrame = CGRect.zero
        nameFrame.origin.x = kCellMargin
        nameFrame.origin.y = kCellMargin
        nameFrame.size = self.nameLabel.sizeThatFits(size)
        self.nameLabel.frame = nameFrame
        
        var statusFrame = CGRect.zero
        statusFrame.origin.x = kCellMargin
        statusFrame.origin.y = nameFrame.maxY + kLabelMargin
        statusFrame.size = self.statusLabel.sizeThatFits(size)
        self.statusLabel.frame = statusFrame
        
        var dividerFrame = CGRect.zero
        dividerFrame.origin.x = kCellMargin
        dividerFrame.origin.y = size.height - 1
        dividerFrame.size.width = size.width - kCellMargin
        dividerFrame.size.height = 1
        self.divier.frame = dividerFrame
    }
    
    /* Adjust labels when new DiningHall is set. */
    var diningHall: DiningHall? = nil 
    {
        didSet {
            if diningHall == nil {
                return
            }
            
            let hall = diningHall!
            self.nameLabel.text = hall.name
            
            let open = hall.isOpen
            self.statusLabel.text = open ? "OPEN" : "CLOSED"
            self.statusLabel.textColor = open ? kColorGreen : kColorRed
            self.statusLabel.font = UIFont.systemFont(ofSize: kFontSize13)
            
            self.setNeedsLayout()
        }
    }
}
