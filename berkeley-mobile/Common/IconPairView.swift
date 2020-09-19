//
//  IconPairView.swift
//  bm-persona
//
//  Created by Kevin Hu on 8/15/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

/// A view containing an icon next to a label.
class IconPairView: UIView {

    init(icon: UIImageView, iconHeight: CGFloat, iconWidth: CGFloat? = nil, attachedView: UILabel) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(attachedView)

        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: iconWidth ?? iconHeight).isActive = true
        icon.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true

        attachedView.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 5).isActive = true
        attachedView.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        attachedView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        heightAnchor.constraint(greaterThanOrEqualTo: icon.heightAnchor).isActive = true
        heightAnchor.constraint(greaterThanOrEqualTo: attachedView.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
