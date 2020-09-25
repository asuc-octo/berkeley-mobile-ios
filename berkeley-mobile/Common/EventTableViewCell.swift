//
//  EventTableViewCell.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/11/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    static let kCellHeight: CGFloat = 86
    
    var eventTaggingColor: UIView!
    var eventName: UILabel!
    var eventTime: UILabel!
    var eventCategory: TagView!
    var eventLogo: UIImageView!
    
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
        backgroundView?.layer.cornerRadius = 12
        selectedBackgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12
        
        backgroundView?.layer.shadowOpacity = 0.25
        backgroundView?.layer.shadowRadius = 5
        backgroundView?.layer.shadowOffset = .zero
        backgroundView?.layer.shadowColor = UIColor.black.cgColor
        backgroundView?.layer.shadowPath = UIBezierPath(rect: contentView.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 22, bottom: 12, right: 16)
        
        backgroundView = UIView()
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
        eventName.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventName.bottomAnchor.constraint(lessThanOrEqualTo: eventTime.topAnchor, constant: -5).isActive = true
        
//        eventLogo.isHidden = true
        eventLogo.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        eventLogo.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventLogo.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
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
    
    func cellConfigure(entry: CalendarEntry) {
        eventName.text = entry.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        eventTime.text = dateFormatter.string(from: entry.date)
        
        eventCategory.text = entry.eventType
        
        let entryColor = EventTableViewCell.getEntryColor(entryType: entry.eventType ?? "")
        eventTaggingColor.backgroundColor = entryColor
        eventCategory.backgroundColor = entryColor
    }
    
    func cellSetImage(image: UIImage) {
        eventLogo.image = image
    }
    
    class func getEntryColor(entryType: String) -> UIColor {
        switch entryType {
        case let type where type.contains("Exhibit"):
            return Color.eventExhibit
        case "Seminar":
            return Color.eventAcademic
        case "Lecture":
            return Color.eventAcademic
        case "Workshop":
            return Color.eventAcademic
        case "Course":
            return Color.eventAcademic
        default:
            return Color.eventDefault
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

