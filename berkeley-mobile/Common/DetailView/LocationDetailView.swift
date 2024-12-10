//
//  LocationDetailView.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

/// The standard view for displaying the distance between the user and an item conforming to `HasLocation`.
class LocationDetailView: IconPairView, DetailView {

    typealias Item = HasLocation

    private var icon: UIImageView!
    private var label: UILabel!

    /// The item configuring this view.
    private var item: HasLocation?
    
    private var walkIcon: UIImage? {
        UIImage(named: "Walk")?.colored(BMColor.blackText)
    }

    weak var delegate: DetailViewDelegate?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        icon.image = walkIcon
    }

    var missingData: Bool {
        guard let item = item else { return true }
        return item.distanceToUser == nil
    }

    func configure(for item: HasLocation) {
        self.item = item
        label.text = "Unknown"
        if let distance = item.distanceToUser {
            label.text = String(format: "%.1f mi", distance)
        }
        delegate?.detailsUpdated(for: self)
    }

    init() {
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true

        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = BMFont.light(12)
        label.textColor = BMColor.blackText
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 2

        super.init(icon: icon, iconHeight: 16, iconWidth: 16, attachedView: label)
        
        icon.image = walkIcon

        // Register for location updates
        LocationManager.notificationCenter.addObserver(
            self,
            selector: #selector(locationUpdated(_:)),
            name: .locationUpdated,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Location Manager Notification

extension LocationDetailView {
    @objc func locationUpdated(_ notification: Notification) {
        guard let item = item else { return }
        configure(for: item)
    }
}
