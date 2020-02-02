//
//  SearchResultCell.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SearchResultCell: MaterialTableViewCell {
    
    private var icon: UIImageView!
    private var title: UILabel!
    private var subTitle: UILabel!
    private var caption: UILabel!
    private var leftStack: UIStackView!
    private var rightStack: UIStackView!
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCornerBorder(cornerRadius: 0.0)
        
        backgroundColor = Color.searchBarBackground
        
        icon = UIImageView(image: UIImage(named: "Placemark")?.colored(Color.searchBarIconColor))
        title = UILabel()
        title.font = Font.regular(16)
        subTitle = UILabel()
        subTitle.font = Font.regular(14)
        caption = UILabel()
        caption.font = Font.regular(12)
        caption.adjustsFontSizeToFitWidth = true
        
        leftStack = UIStackView(arrangedSubviews: [icon, caption], axis: .vertical, distribution: .fillProportionally, spacing: 0.0)
        rightStack = UIStackView(arrangedSubviews: [title, subTitle], axis: .vertical, distribution: .fillProportionally, spacing: 0.0)
        leftStack.alignment = .center
        
        self.addSubViews([leftStack, rightStack])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftStack.setConstraintsToView(left: self, lConst: 0.02 * self.frame.width)
        rightStack.setConstraintsToView(right: self)
        
        self.addConstraints([
            NSLayoutConstraint(item: leftStack as Any, attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self, attribute: .centerY,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightStack as Any, attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self, attribute: .centerY,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightStack as Any, attribute: .left,
                               relatedBy: .equal,
                               toItem: leftStack, attribute: .right,
                               multiplier: 1.0, constant: 0.03*self.frame.width)
            ])
        leftStack.setWidthConstraint(self.frame.height)
        icon.setWidthConstraint(0.4*self.frame.height)
        self.layoutIfNeeded()
    }
    
    func cellConfigure(_ currentPlacemark: MapPlacemark) {
        title.text = currentPlacemark.searchName
        subTitle.text = currentPlacemark.locationName // TODO: - fix
        
        guard
            let userLoc = locationManager.location,
            let placemarkLoc = currentPlacemark.location
        else {
            return
        }
        let distance = round(userLoc.distance(from: placemarkLoc) / 1600.0 * 10) / 10
        self.caption.text = "\(distance) mi"
    }
    
    private func parsePlacemark(_ placemark: CLPlacemark) -> String {
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? ""
        )
        return addressLine
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UIStackView
extension UIStackView {
    convenience init(arrangedSubviews: [UIView]? = nil, axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat) {
        if let arrangedSubviews = arrangedSubviews {
            self.init(arrangedSubviews: arrangedSubviews)
        } else {
            self.init()
        }
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
    }
}
