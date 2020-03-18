//
//  ResourceTableViewCell.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 3/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class ResourceTableViewCell: UITableViewCell {

    private var resourceName: UILabel!
    private var resourceCategory: UILabel!
    private var resourceImage: UIImageView!
    
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
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Color.modalBackground
            
        selectedBackgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        
        resourceName = UILabel()
        resourceCategory = UILabel()
        resourceImage = UIImageView()
        
        contentView.addSubview(resourceName)
        contentView.addSubview(resourceCategory)
        contentView.addSubview(resourceImage)
        
        resourceName.translatesAutoresizingMaskIntoConstraints = false
        resourceCategory.translatesAutoresizingMaskIntoConstraints = false
        resourceImage.translatesAutoresizingMaskIntoConstraints = false
        
        resourceName.font = Font.bold(18)
        resourceName.numberOfLines = 2
        resourceName.adjustsFontSizeToFitWidth = true
        resourceName.minimumScaleFactor = 0.7
        resourceName.sizeToFit()
        resourceName.layoutMargins = UIEdgeInsets(top: 21, left: 14, bottom: 0, right: 0)
        resourceName.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        resourceName.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        resourceName.rightAnchor.constraint(equalTo: resourceImage.leftAnchor, constant: -10).isActive = true
        resourceName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        resourceImage.image = UIImage(named: "DoeGlade")  // TODO: - Dynamically load once backend updated
        resourceImage.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: -5)
        resourceImage.layer.masksToBounds = true
        resourceImage.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        resourceImage.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        resourceImage.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        resourceImage.widthAnchor.constraint(equalToConstant: contentView.frame.height * 2.33).isActive = true
        resourceImage.contentMode = .scaleAspectFill

        resourceCategory.font = Font.regular(12)
        resourceCategory.padding = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        resourceCategory.frame.size.height = 18
        resourceCategory.layer.masksToBounds = true
        resourceCategory.layer.cornerRadius = resourceCategory.frame.height / 1.5
        resourceCategory.backgroundColor = Color.eventDefault
        resourceCategory.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        resourceCategory.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        resourceCategory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func cellConfigure(entry: Resource) {
        resourceName.text = entry.name
        
        resourceCategory.text = "Resource"
        
        resourceImage.image = UIImage(named: "DoeGlade")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
