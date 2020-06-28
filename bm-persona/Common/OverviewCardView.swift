//
//  OverviewCardView.swift
//  bm-persona
//
//  Created by Shawn Huang on 6/27/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

enum OverviewElements {
    case address
    case phone
    case distance
    case openTimes
    case occupancy
    case favorite
}

class OverviewCardView: CardView {
    var item: SearchItem!
    var userLocation: CLLocation?
    var distanceViewAdded = false
    var addressView: UIView?
    var excludedElements: [OverviewElements] = []
    
    public init(item: SearchItem, excludedElements: [OverviewElements] = [], userLocation: CLLocation? = nil) {
        super.init(frame: CGRect.zero)
        self.isUserInteractionEnabled = true
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        self.item = item
        self.excludedElements = []
        self.userLocation = userLocation
        
        setupStaticElements()
        setupOptionalElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Setup
    func setupStaticElements() {
        // elements that are always on the card (image replaced with placeholder if not available)
        self.addSubview(nameLabel)
        self.addSubview(imageView)
        nameLabel.text = item.searchName
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: kViewMargin).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -1 * kViewMargin).isActive = true
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: kViewMargin).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        // constrain width of the image to be 40% of card width, to prevent image from taking up too much space on the card
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        imageView.image = UIImage(named: "DoeGlade")
        if var itemWithImage = item as? HasImage {
            if let itemImage = itemWithImage.image {
                imageView.image = itemImage
            } else {
                DispatchQueue.global().async {
                    guard let imageURL = itemWithImage.imageURL, let imageData = try? Data(contentsOf: imageURL) else { return }
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        itemWithImage.image = image
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    func setupOptionalElements() {
        // TODO: Make SearchItem's address optional and check here before adding
        if !excludedElements.contains(.address) {
            let longAddress = item.locationName
            if let ind = longAddress.range(of: "Berkeley")?.upperBound {
                let newAddress = longAddress[..<ind]
                addressLabel.text = String(newAddress)
            } else {
                addressLabel.text = longAddress
            }
            addressView = iconPairView(icon: addressIcon, iconHeight: 16, attachedView: addressLabel)
            leftVerticalStack.addArrangedSubview(addressView!)
        }
        
        //if !excludedElements.contains(.phone), let itemWithPhone = item as? HasPhoneNumber, let phoneNumber = itemWithPhone.phoneNumber {
            phoneLabel.text = "650-650-6506" //phoneNumber
            secondRowHorizontalStack.addArrangedSubview(iconPairView(icon: phoneIcon, iconHeight: 16, attachedView: phoneLabel))
        //}

        updateDistanceDisplay()

        if secondRowHorizontalStack.arrangedSubviews.count > 0 {
            leftVerticalStack.addArrangedSubview(secondRowHorizontalStack)
            secondRowHorizontalStack.leftAnchor.constraint(equalTo: leftVerticalStack.leftAnchor).isActive = true
            secondRowHorizontalStack.rightAnchor.constraint(equalTo: leftVerticalStack.rightAnchor).isActive = true
        }

        let date = Date()
        if !excludedElements.contains(.openTimes), let itemWithOpenTimes = item as? HasOpenTimes, let intervals = itemWithOpenTimes.weeklyHours?.hoursForWeekday(DayOfWeek.weekday(date)) {
            openTimesStack.addArrangedSubview(iconPairView(icon: clockIcon, iconHeight: 16, attachedView: openTimeLabel))

            let formatter = DateIntervalFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            /*If dining hall has open hours for today, set the label to show the current
             or next open interval. If there are no open times in the rest of the day,
             set label to "Closed Today".*/
            openTimeLabel.text = "Closed Today"
            var nextOpenInterval: DateInterval? = nil
            for interval in intervals {
                if interval.contains(date) {
                    nextOpenInterval = interval
                    break
                } else if date.compare(interval.start) == .orderedAscending {
                    if nextOpenInterval == nil {
                        nextOpenInterval = interval
                    } else if interval.compare(nextOpenInterval!) == .orderedAscending {
                        nextOpenInterval = interval
                    }
                }
            }
            /* Remove the date, and only include hour and minute in string display.
             Otherwise, string is too long when interval spans two days (e.g. 9pm-12:30am) */
            if nextOpenInterval != nil,
                let start = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute], from: nextOpenInterval!.start)),
                let end = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute], from: nextOpenInterval!.end)) {
                openTimeLabel.text = formatter.string(from: start, to: end)
            }

            if let isOpen = itemWithOpenTimes.isOpen {
                if isOpen {
                    openTag.text = "Open"
                    openTag.backgroundColor = Color.openTag
                } else {
                    openTag.text = "Closed"
                    openTag.backgroundColor = Color.closedTag
                }
                openTag.widthAnchor.constraint(equalToConstant: 50).isActive = true
                openTimesStack.addArrangedSubview(openTag)
            }
            leftVerticalStack.addArrangedSubview(openTimesStack)
            openTimesStack.leftAnchor.constraint(equalTo: leftVerticalStack.leftAnchor).isActive = true
            openTimesStack.rightAnchor.constraint(equalTo: leftVerticalStack.rightAnchor).isActive = true
        }
        
        if leftVerticalStack.arrangedSubviews.count > 0 {
            self.addSubview(leftVerticalStack)
            leftVerticalStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
            leftVerticalStack.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -1 * kViewMargin).isActive = true
            leftVerticalStack.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
            leftVerticalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        }

        if !excludedElements.contains(.occupancy), let itemWithOccupancy = item as? HasOccupancy, let status = itemWithOccupancy.getOccupancyStatus(date: Date()) {
            occupancyBadge.widthAnchor.constraint(equalToConstant: 50).isActive = true
            let occupancyView = iconPairView(icon: chairImage, iconHeight: 16, iconWidth: 28, attachedView: occupancyBadge)
            switch status {
            case OccupancyStatus.high:
                occupancyBadge.text = "High"
                occupancyBadge.backgroundColor = Color.highCapacityTag
            case OccupancyStatus.medium:
                occupancyBadge.text = "Medium"
                occupancyBadge.backgroundColor = Color.medCapacityTag
            case OccupancyStatus.low:
                occupancyBadge.text = "Low"
                occupancyBadge.backgroundColor = Color.lowCapacityTag
            }
            belowImageHorizontalStack.addArrangedSubview(occupancyView)
        }
        
        if !excludedElements.contains(.favorite), let favoritableItem = item as? CanFavorite {
            if favoritableItem.isFavorited {
                faveButton.setImage(UIImage(named: "Gold Star"), for: .normal)
            } else {
                faveButton.setImage(UIImage(named: "Grey Star"), for: .normal)
            }
            faveButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
            faveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
            belowImageHorizontalStack.addArrangedSubview(faveButton)
        }

        if belowImageHorizontalStack.arrangedSubviews.count > 0 {
            self.addSubview(belowImageHorizontalStack)
            belowImageHorizontalStack.leftAnchor.constraint(greaterThanOrEqualTo: imageView.leftAnchor).isActive = true
            belowImageHorizontalStack.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
            belowImageHorizontalStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: kViewMargin).isActive = true
            belowImageHorizontalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        }
    }
    
    private func iconPairView(icon: UIImageView, iconHeight: CGFloat, iconWidth: CGFloat? = nil, attachedView: UILabel) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)
        view.addSubview(attachedView)
        icon.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: iconWidth ?? iconHeight).isActive = true
        icon.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true
        attachedView.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 5).isActive = true
        attachedView.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        attachedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualTo: icon.heightAnchor).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualTo: attachedView.heightAnchor).isActive = true
        return view
    }
    
    public func updateLocation(userLocation: CLLocation) {
        self.userLocation = userLocation
        updateDistanceDisplay()
    }
    
    private func updateDistanceDisplay() {
        if !excludedElements.contains(.distance), let itemWithLocation = item as? HasLocation, let userLocation = self.userLocation {
            let dist = itemWithLocation.getDistanceToUser(userLoc: userLocation)
            distLabel.text = String(dist) + " mi"
            if !distanceViewAdded, dist < type(of: itemWithLocation).invalidDistance {
                secondRowHorizontalStack.addArrangedSubview(iconPairView(icon: distIcon, iconHeight: 16, attachedView: distLabel))
                distanceViewAdded = true
                if !leftVerticalStack.arrangedSubviews.contains(secondRowHorizontalStack) {
                    if let addressView = self.addressView, let index = leftVerticalStack.arrangedSubviews.firstIndex(of: addressView) {
                        leftVerticalStack.insertArrangedSubview(secondRowHorizontalStack, at: index + 1)
                    } else {
                        leftVerticalStack.insertArrangedSubview(secondRowHorizontalStack, at: 0)
                    }
                }
            }
        }
    }
    
    // MARK: - StackViews
    let leftVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = kViewMargin
        return stack
    }()
    
    let secondRowHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    let openTimesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    let belowImageHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .equalSpacing
        stack.spacing = kViewMargin
        return stack
    }()
    
    // MARK: - View Elements
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(24)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 2
        return label
    }()
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let addressIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Placemark")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    let clockIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Clock")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let openTimeLabel: UILabel = {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    let openTag: TagView = {
        let tag = TagView(origin: .zero, text: "", color: .clear)
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
    
    let chairImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Chair")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let occupancyBadge:TagView = {
        let occ = TagView(origin: .zero, text: "", color: .clear)
        occ.translatesAutoresizingMaskIntoConstraints = false
        return occ
    }()
    
    let faveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc func toggleFave(sender: UIButton) {
        if var favoritableItem = item as? CanFavorite {
            if favoritableItem.isFavorited {
                sender.setImage(UIImage(named: "Grey Star"), for: .normal)
                favoritableItem.isFavorited = false
            } else {
                sender.setImage(UIImage(named: "Gold Star"), for: .normal)
                favoritableItem.isFavorited = true
            }
        }
    }
    
    let phoneIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Phone")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let phoneLabel: UILabel =  {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    let distIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Walk")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let distLabel: UILabel =  {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
}
