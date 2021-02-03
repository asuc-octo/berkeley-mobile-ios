//
//  EventTableViewCell.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/11/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kLogoHeight: CGFloat = 20

class EventTableViewCell: CardTableViewCell {
    
    static let kCellHeight: CGFloat = 86
    static let kCellIdentifier: String = "eventCell"
    
    var eventTaggingColor: UIView!
    var eventName: UILabel!
    var eventTime: UILabel!
    var eventCategory: TagView!
    var eventLogo: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 22, bottom: 12, right: 16)
        
        eventTaggingColor = UIView()
        eventName = UILabel()
        eventTime = UILabel()
        eventCategory = TagView()
        eventLogo = UIImageView()
        
        contentView.addSubview(eventTaggingColor)
        contentView.addSubview(eventName)
        contentView.addSubview(eventTime)
        contentView.addSubview(eventCategory)
        contentView.addSubview(eventLogo)
        
        eventTaggingColor.translatesAutoresizingMaskIntoConstraints = false
        eventName.translatesAutoresizingMaskIntoConstraints = false
        eventTime.translatesAutoresizingMaskIntoConstraints = false
        eventCategory.translatesAutoresizingMaskIntoConstraints = false
        eventLogo.translatesAutoresizingMaskIntoConstraints = false
        
        eventTaggingColor.backgroundColor = Color.eventDefault
        eventTaggingColor.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        eventTaggingColor.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        eventTaggingColor.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        eventTaggingColor.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        eventName.font = Font.bold(18)
        eventName.numberOfLines = 2
        eventName.adjustsFontSizeToFitWidth = true
        eventName.minimumScaleFactor = 0.7
        eventName.setContentHuggingPriority(.required, for: .vertical)
        eventName.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        eventName.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        eventName.rightAnchor.constraint(equalTo: eventLogo.leftAnchor, constant: -15).isActive = true
        eventName.bottomAnchor.constraint(lessThanOrEqualTo: eventTime.topAnchor, constant: -5).isActive = true
        
        eventLogo.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        eventLogo.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventLogo.widthAnchor.constraint(equalToConstant: kLogoHeight).isActive = true
        eventLogo.heightAnchor.constraint(equalToConstant: kLogoHeight).isActive = true
        eventLogo.contentMode = .scaleAspectFit
        
        eventTime.font = Font.light(12)
        eventTime.numberOfLines = 2
        eventTime.setContentCompressionResistancePriority(.required, for: .vertical)
        eventTime.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        eventTime.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        eventTime.rightAnchor.constraint(equalTo: eventCategory.leftAnchor, constant: -5).isActive = true
        
        eventCategory.backgroundColor = Color.eventDefault
        eventCategory.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventCategory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func cellConfigure(event: CalendarEvent, type: String?, color: UIColor?) {
        eventName.text = event.name
        eventTime.text = event.dateString
        
        eventCategory.text = type
        eventCategory.isHidden = type == nil
        eventCategory.backgroundColor = color
        eventTaggingColor.backgroundColor = color ?? Color.eventDefault
    }
    
    func cellSetImage(image: UIImage, tapGesture: UITapGestureRecognizer) {
        // Ensure each cell only has 1 recognizer for the image
        for r in eventLogo.gestureRecognizers ?? [] {
            eventLogo.removeGestureRecognizer(r)
        }
        
        eventLogo.image = image
        eventLogo.addGestureRecognizer(tapGesture)
        eventLogo.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

