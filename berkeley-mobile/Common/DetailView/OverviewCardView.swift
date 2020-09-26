//
//  OverviewCardView.swift
//  bm-persona
//
//  Created by Shawn Huang on 6/27/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
fileprivate let kViewMargin: CGFloat = 10


// all the possible elements on the card, used to exclude certain elements even if they are available
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
    var addressView: UIView?
//    let tap = UITapGestureRecognizer(target: self, action: #selector(self.openAddressInMap(_:)))
    // elements to exclude from the card even if they are available
    var excludedElements: [OverviewElements] = []
    
    public init(item: SearchItem, excludedElements: [OverviewElements] = []) {
        super.init(frame: CGRect.zero)
        self.isUserInteractionEnabled = true
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        self.item = item
        self.excludedElements = excludedElements
        
        
        setUpStaticElements()
        setUpOptionalElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Setup
    func setUpStaticElements() {
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
    
    // for each element on the card, checks if item conforms to associated protocol, has non-nil value for the element, and is not excluded before adding
    func setUpOptionalElements() {
        // TODO: Make SearchItem's address optional and check here before adding
        if !excludedElements.contains(.address), let itemWithLocation = item as? HasLocation, let longAddress = itemWithLocation.address {
            if let ind = longAddress.range(of: "Berkeley")?.upperBound {
                let newAddress = longAddress[..<ind]
                addressLabel.text = String(newAddress)
            } else {
                addressLabel.text = longAddress
            }
            addressView = IconPairView(icon: addressIcon, iconHeight: 16, attachedView: addressLabel)
            leftVerticalStack.addArrangedSubview(addressView!)
            addressView!.leftAnchor.constraint(equalTo: leftVerticalStack.leftAnchor).isActive = true
            addressView!.rightAnchor.constraint(equalTo: leftVerticalStack.rightAnchor).isActive = true
        }
        
        if !excludedElements.contains(.phone), let itemWithPhone = item as? HasPhoneNumber, let phoneNumber = itemWithPhone.phoneNumber {
            phoneLabel.text = phoneNumber
            secondRowHorizontalStack.addArrangedSubview(IconPairView(icon: phoneIcon, iconHeight: 16, attachedView: phoneLabel))
        }

        if !excludedElements.contains(.distance), let itemWithLocation = item as? HasLocation {
            locationDetailView.delegate = self
            locationDetailView.configure(for: itemWithLocation)
            secondRowHorizontalStack.addArrangedSubview(locationDetailView)
        }

        // if the row stack has any elements add it to the vertical stack, otherwise don't add it to prevent spacing issues
        if !secondRowHorizontalStack.emptyOrChildrenHidden {
            leftVerticalStack.addArrangedSubview(secondRowHorizontalStack)
            secondRowHorizontalStack.leftAnchor.constraint(equalTo: leftVerticalStack.leftAnchor).isActive = true
            secondRowHorizontalStack.rightAnchor.constraint(equalTo: leftVerticalStack.rightAnchor).isActive = true
        }
        
        if !excludedElements.contains(.openTimes), let itemWithOpenTimes = item as? HasOpenTimes, itemWithOpenTimes.weeklyHours != nil {
            openTimesStack.addArrangedSubview(IconPairView(icon: clockIcon, iconHeight: 16, attachedView: openTimeLabel))

            let formatter = DateIntervalFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            /* If dining hall has open hours for today, set the label to show the current
             or next open interval. If there are no open times in the rest of the day,
             set label to "Closed Today".*/
            openTimeLabel.text = "Closed Today"
            let nextOpenInterval = itemWithOpenTimes.nextOpenInterval()
            /* Remove the date, and only include hour and minute in string display.
             Otherwise, string is too long when interval spans two days (e.g. 9pm-12:30am) */
            if let interval = nextOpenInterval,
                let start = interval.start.timeOnly(),
                let end = interval.end.timeOnly() {
                openTimeLabel.text = formatter.string(from: start, to: end)
            }

            if let isOpen = itemWithOpenTimes.isOpen {
                openTimesStack.addArrangedSubview(isOpen ? TagView.open: TagView.closed)
            }
            leftVerticalStack.addArrangedSubview(openTimesStack)
            openTimesStack.leftAnchor.constraint(equalTo: leftVerticalStack.leftAnchor).isActive = true
            openTimesStack.rightAnchor.constraint(lessThanOrEqualTo: leftVerticalStack.rightAnchor).isActive = true
        }
        
        // add the vertical stack to the card if it contains any elements
        if leftVerticalStack.arrangedSubviews.count > 0 {
            self.addSubview(leftVerticalStack)
            leftVerticalStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
            leftVerticalStack.rightAnchor.constraint(equalTo: imageView.leftAnchor, constant: -1 * kViewMargin).isActive = true
            leftVerticalStack.topAnchor.constraint(greaterThanOrEqualTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
            leftVerticalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        }

        if !excludedElements.contains(.occupancy), let itemWithOccupancy = item as? HasOccupancy, let status = itemWithOccupancy.getCurrentOccupancyStatus(isOpen: (item as? HasOpenTimes)?.isOpen) {
            let occupancyView = IconPairView(icon: chairImage, iconHeight: 16, iconWidth: 28, attachedView: status.badge())
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

        // add the stack below the image if it contains any elements. otherwise, the image will stretch down to the bottom of the card
        if belowImageHorizontalStack.arrangedSubviews.count > 0 {
            self.addSubview(belowImageHorizontalStack)
            belowImageHorizontalStack.leftAnchor.constraint(greaterThanOrEqualTo: imageView.leftAnchor).isActive = true
            belowImageHorizontalStack.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
            belowImageHorizontalStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: kViewMargin).isActive = true
            belowImageHorizontalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * kViewMargin).isActive = true
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
        stack.distribution = .fillProportionally
        stack.spacing = 5
        return stack
    }()
    
    let openTimesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 5
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
        label.minimumScaleFactor = 0.4
        label.numberOfLines = 3
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
        label.numberOfLines = 0
        
        label.isUserInteractionEnabled = true
//        label.addGestureRecognizer(tap)
        
        return label
    }()
    
    @objc func openAddressInMap(_ sender: UITapGestureRecognizer? = nil) {
//        let myAddress = addressLabel.text
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(myAddress!) { (placemarks, error) in
//            guard let placemarks = placemarks?.first else { return }
//            let location = placemarks.location?.coordinate ?? CLLocationCoordinate2D()
//            guard let url = URL(string:"http://maps.apple.com/?daddr=\(location.latitude),\(location.longitude)") else { return }
//            UIApplication.shared.open(url)
//        }
        print("tapped")
    }
    
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
        label.numberOfLines = 2
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
    
    let faveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
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
        label.numberOfLines = 2
        return label
    }()
    
    let locationDetailView: LocationDetailView = {
        return LocationDetailView()
    }()
}

// MARK: - DetailView Delegate

extension OverviewCardView: DetailViewDelegate {
    func detailsUpdated(for view: UIView) {
        if let locationDetailView = view as? LocationDetailView {
            locationDetailView.isHidden = locationDetailView.missingData

            // if the row stack wasn't originally added (no phone and distance initially), add it under the address view or at the top if address view isn't added
            if !locationDetailView.isHidden && !leftVerticalStack.arrangedSubviews.contains(secondRowHorizontalStack) {
                if let addressView = self.addressView, let index = leftVerticalStack.arrangedSubviews.firstIndex(of: addressView) {
                    leftVerticalStack.insertArrangedSubview(secondRowHorizontalStack, at: index + 1)
                } else {
                    leftVerticalStack.insertArrangedSubview(secondRowHorizontalStack, at: 0)
                }
            }
        }
    }
}
