//
//  ResourceTableViewCell.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 3/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class ResourceTableViewCell: UITableViewCell, ImageViewCell {
    
    static let kCellIdentifier = "resourceCell"

    private var resourceName: UILabel = UILabel()
    private var resourceCategory: TagView = TagView()
    var cellImageView: UIImageView = UIImageView()
    
    static let defaultImage = UIImage(named: "DoeGlade")
    var currentLoadUUID: UUID?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancelImageOnReuse()
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup spacing between cells
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:7.5, left:5, bottom:7.5, right:5))
        backgroundView?.frame = contentView.frame
        selectedBackgroundView?.frame = contentView.frame
        
        // Setup corner radius and drop shadow
        backgroundColor = .clear
        backgroundView?.backgroundColor = Color.modalBackground
        
        backgroundView?.layer.masksToBounds = false
        backgroundView?.layer.cornerRadius = 6
        selectedBackgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 6
        
        backgroundView?.layer.shadowOpacity = 0.25
        backgroundView?.layer.shadowRadius = 5
        backgroundView?.layer.shadowOffset = .zero
        backgroundView?.layer.shadowColor = UIColor.black.cgColor
        backgroundView?.layer.shadowPath = UIBezierPath(rect: contentView.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        backgroundView = UIView()
        
        contentView.addSubview(resourceName)
        contentView.addSubview(resourceCategory)
        contentView.addSubview(cellImageView)
        
        resourceName.translatesAutoresizingMaskIntoConstraints = false
        resourceCategory.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        resourceName.font = Font.bold(18)
        resourceName.numberOfLines = 2
        resourceName.adjustsFontSizeToFitWidth = true
        resourceName.minimumScaleFactor = 0.4
        resourceName.setContentHuggingPriority(.required, for: .vertical)
        resourceName.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        resourceName.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        resourceName.rightAnchor.constraint(equalTo: cellImageView.leftAnchor, constant: -10).isActive = true
        resourceName.bottomAnchor.constraint(lessThanOrEqualTo: resourceCategory.topAnchor, constant: -5).isActive = true
        
        cellImageView.image = UIImage(named: "DoeGlade")  // TODO: - Dynamically load once backend updated
        cellImageView.layer.masksToBounds = true
        cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        cellImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        cellImageView.widthAnchor.constraint(equalToConstant: contentView.frame.height * 2.33).isActive = true
        cellImageView.contentMode = .scaleAspectFill

        resourceCategory.backgroundColor = Color.eventDefault
        resourceCategory.setContentCompressionResistancePriority(.required, for: .vertical)
        resourceCategory.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        resourceCategory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func cellConfigure(entry: Resource) {
        resourceName.text = entry.name
        
        resourceCategory.text = "Resource"
        
        cellImageView.image = UIImage(named: "DoeGlade")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
