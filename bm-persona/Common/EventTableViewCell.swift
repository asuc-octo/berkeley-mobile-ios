//
//  EventTableViewCell.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/11/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    private var eventTaggingColor: UILabel!
    private var eventName: UILabel!
    private var eventTime: UILabel!
    private var eventCategory: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        
        eventTaggingColor = UILabel()
        eventName = UILabel()
        eventTime = UILabel()
        eventCategory = UILabel()
        
        contentView.addSubview(eventTaggingColor)
        contentView.addSubview(eventName)
        contentView.addSubview(eventTime)
        contentView.addSubview(eventCategory)
        
        eventTaggingColor.translatesAutoresizingMaskIntoConstraints = false
        eventName.translatesAutoresizingMaskIntoConstraints = false
        eventTime.translatesAutoresizingMaskIntoConstraints = false
        eventCategory.translatesAutoresizingMaskIntoConstraints = false
        
        eventTaggingColor.backgroundColor = Color.eventDefault
        eventTaggingColor.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        eventTaggingColor.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        eventTaggingColor.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        eventTaggingColor.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        eventTaggingColor.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentView.frame.width - 10).isActive = true
        eventTaggingColor.layer.masksToBounds = true
        
        eventName.font = Font.bold(18)
        eventName.numberOfLines = 2
        eventName.adjustsFontSizeToFitWidth = true
        eventName.minimumScaleFactor = 0.7
        eventName.sizeToFit()
        eventName.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        eventName.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        eventName.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        eventName.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        eventTime.font = Font.regular(16)
        eventTime.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        eventTime.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        eventTime.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventTime.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        
        eventCategory.font = Font.regular(12)
        eventCategory.padding = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        eventCategory.frame.size.height = 18
        eventCategory.layer.masksToBounds = true
        eventCategory.layer.cornerRadius = eventCategory.frame.height / 1.5
        eventCategory.backgroundColor = Color.eventDefault
        eventCategory.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        eventCategory.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        eventCategory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: 4).isActive = true
    }
    
    func cellConfigure(entry: CalendarEntry) {
        eventName.text = entry.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        eventTime.text = dateFormatter.string(from: entry.date!)
        
        eventCategory.text = entry.eventType
        
        let entryColor = EventTableViewCell.getEntryColor(entryType: entry.eventType ?? "")
        eventTaggingColor.backgroundColor = entryColor
        eventCategory.backgroundColor = entryColor
    }
    
    class func getEntryColor(entryType: String) -> UIColor {
        switch entryType {
        case "Academic":
            return Color.eventAcademic
        case "Holiday":
            return Color.eventHoliday
        case "General":
            return Color.eventHoliday
        case "College of Engineering":
            return Color.eventAcademic
        case "College of Letters and Sciences":
            return Color.eventAcademic
        case "College of Chemistry":
            return Color.eventAcademic
        case "College of Natural Resources":
            return Color.eventAcademic
        default:
            return Color.eventDefault
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }

    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }

        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0

        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }

        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)

        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth

        return contentSize
    }
}

