//
//  DiningMenuCell.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class DiningMenuCell: UITableViewCell {
    
    static let kCellIdentifier = "diningCell"
    var item: DiningItem!
    var icons: [UIImageView] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:0, left:5, bottom:0, right:5))
        self.selectionStyle = .none
        
        backgroundColor = .clear
        contentView.layer.masksToBounds = false
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds.insetBy(dx: 4, dy: 4)).cgPath
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(faveButton)
        contentView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        
        faveButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        faveButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        faveButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        faveButton.widthAnchor.constraint(equalTo: faveButton.heightAnchor).isActive = true
    }
    
    func setRestrictionIcons() {
        for icon in icons {
            icon.removeFromSuperview()
        }
        var lastLeftAnchor = faveButton.leftAnchor
        for restriction in item.restrictions {
            if restriction.icon == nil {
                continue
            }
            let image = UIImageView()
            contentView.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .scaleAspectFit
            image.clipsToBounds = true
            if lastLeftAnchor == faveButton.leftAnchor {
                image.rightAnchor.constraint(equalTo: lastLeftAnchor, constant: -10).isActive = true
            } else {
                image.rightAnchor.constraint(equalTo: lastLeftAnchor).isActive = true
            }
            image.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
            image.widthAnchor.constraint(equalTo: faveButton.heightAnchor).isActive = true
            image.image = restriction.icon!
            icons.append(image)
            lastLeftAnchor = image.leftAnchor
        }
        nameLabel.rightAnchor.constraint(lessThanOrEqualTo: lastLeftAnchor, constant: -10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = Font.medium(16)
        label.textColor = Color.blackText

        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.numberOfLines = 1
        return label
    }()
    
    let faveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

}

extension DiningMenuCell {
    
    @objc func toggleFave(sender: UIButton) {
        item.isFavorited = !item.isFavorited
        updateFaveButton()
    }
    
    func updateFaveButton() {
        //TODO: use fave icons
        if item.isFavorited {
            faveButton.setImage(UIImage(named: "Gold Star"), for: .normal)
        } else {
            faveButton.setImage(UIImage(named: "Grey Star"), for: .normal)
        }
    }
    
}
