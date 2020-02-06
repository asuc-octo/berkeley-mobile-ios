//
//  CustomTableViewCell.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {


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
        contentView.addSubview(capLabel)
        
        nameLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -53).isActive = true
        
        recLabel.bottomAnchor.constraint(equalTo: self.nameLabel.topAnchor, constant: -3).isActive = true
        recLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16).isActive = true
        recLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        
        cellImage.widthAnchor.constraint(equalToConstant:104.5).isActive = true
        cellImage.heightAnchor.constraint(equalToConstant:93).isActive = true
        cellImage.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-4.5).isActive = true
        cellImage.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        
        personImage.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor, constant: 17).isActive = true
        personImage.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor).isActive = true
        personImage.leftAnchor.constraint(equalTo:contentView.leftAnchor, constant: 16).isActive = true
        personImage.widthAnchor.constraint(equalToConstant:15).isActive = true
        personImage.heightAnchor.constraint(equalToConstant:15).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor, constant: 17).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 41).isActive = true

        chairImage.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor, constant: 13).isActive = true
        chairImage.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor).isActive = true
        chairImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 96).isActive = true
        chairImage.widthAnchor.constraint(equalToConstant:24).isActive = true
        chairImage.heightAnchor.constraint(equalToConstant:24).isActive = true
        
        capLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor, constant: 18).isActive = true
        capLabel.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor).isActive = true
        capLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 152).isActive = true
        
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
        //img.image = UIImage(named: "yosemite.jpg")
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
        img.contentMode = .scaleAspectFill
        //img.image = UIImage(named: "yosemite.jpg")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
     }()
     
    let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
     
    let chairImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        //img.image = UIImage(named: "yosemite.jpg")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
     
    let capLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
}
