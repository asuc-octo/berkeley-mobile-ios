//
//  ResourceTableViewCell.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    
    static let kCellIdentifier = "libraryCell"
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 5
            frame.size.width -= 10
            super.frame = frame
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:0, left:0, bottom:10, right:0))
        
        // add shadow on cell
        backgroundColor = .clear
        contentView.layer.masksToBounds = false
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds.insetBy(dx: 4, dy: 4)).cgPath
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //branch, make PR / merge into develop , make sure base branch you are merging into is develop!!!!!
        contentView.addSubview(nameLabel)
        contentView.addSubview(cellImage)
        contentView.addSubview(recLabel)
        contentView.addSubview(personImage)
        contentView.addSubview(timeLabel)
        contentView.addSubview(chairImage)
        contentView.addSubview(capBadge)
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 16, right: 5)
        
        recLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        recLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        
        nameLabel.heightAnchor.constraint(equalToConstant: 65).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: recLabel.layoutMarginsGuide.bottomAnchor, constant: 5).isActive = true
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.numberOfLines = 2
        
        cellImage.widthAnchor.constraint(equalToConstant: 104.5).isActive = true
        cellImage.heightAnchor.constraint(equalToConstant: 93).isActive = true
        cellImage.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 12).isActive = true
        cellImage.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        cellImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        personImage.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        personImage.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        personImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        personImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        personImage.contentMode = .scaleAspectFit
        
        capBadge.centerYAnchor.constraint(equalTo: personImage.centerYAnchor).isActive = true
        capBadge.rightAnchor.constraint(equalTo: cellImage.leftAnchor, constant: -16).isActive = true
        capBadge.widthAnchor.constraint(equalToConstant: 50).isActive = true

        chairImage.centerYAnchor.constraint(equalTo: personImage.centerYAnchor).isActive = true
        chairImage.rightAnchor.constraint(equalTo: capBadge.leftAnchor, constant: -7).isActive = true
        chairImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        chairImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        chairImage.contentMode = .scaleAspectFit

        timeLabel.centerYAnchor.constraint(equalTo: personImage.centerYAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: personImage.rightAnchor, constant: 5).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: chairImage.leftAnchor, constant: -5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black

        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(red: 44.0 / 255.0, green: 44.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cellImage:UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.clipsToBounds = true
       return img
    }()
    
    let recLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.textColor = UIColor(red: 138.0 / 255.0, green: 135.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
     
    let personImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Walk")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
     }()
     
    let timeLabel:UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
     
    let chairImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Chair")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let capBadge:TagView = {
        let cap = TagView(origin: .zero, text: "", color: .clear)
        cap.translatesAutoresizingMaskIntoConstraints = false
        return cap
    }()
    
    
}
