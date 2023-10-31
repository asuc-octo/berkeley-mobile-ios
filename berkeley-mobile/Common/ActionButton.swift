//
//  ActionButton.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/10/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

/// The default padding to use for this button.
fileprivate let kButtonPadding: UIEdgeInsets = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
/// A stylized button with a background color, rounded corners, and a drop shadow.
class ActionButton: UIButton {
    var defaultColor: UIColor
    var pressedColor: UIColor

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? pressedColor : defaultColor
        }
    }

    init(title: String, font: UIFont = Font.medium(12), defaultColor: UIColor = BMColor.ActionButton.background, pressedColor: UIColor = BMColor.ActionButton.highlighted) {
        self.defaultColor = defaultColor
        self.pressedColor = pressedColor
        super.init(frame: .zero)
        contentEdgeInsets = kButtonPadding
        isHighlighted = false

        // Set rounded corners and drop shadow
        layer.cornerRadius = 12
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath

        // Set title text and font
        guard let label = titleLabel else { return }
        setTitle(title, for: .normal)
        label.font = font
        label.textColor = BMColor.ActionButton.color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class RoundedActionButton: UIButton {
    
    

    init(title: String, font: UIFont = Font.medium(12), color: UIColor = UIColor.gray, iconImage: UIImage?, iconSize: CGFloat? = 24, cornerRadius: CGFloat = 20, iconOffset: CGFloat = -70) {
        super.init(frame: .zero)
        contentEdgeInsets = UIEdgeInsets(top: 13, left: (iconImage != nil) ? 40 : 16, bottom: 13, right: 16)
        backgroundColor = color
        

        // Set rounded corners and drop shadow
        layer.cornerRadius = cornerRadius
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath

        // Set title text and font
        guard let label = titleLabel else { return }
        setTitle(title, for: .normal)
        label.font = font
        label.textColor = BMColor.ActionButton.color
        
        // Set leading icon if there is one
        if iconImage != nil {
            let iconView = UIImageView()
            iconView.image = iconImage
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            addSubview(iconView)
            iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: iconOffset).isActive = true
            iconView.widthAnchor.constraint(equalToConstant: iconSize!).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: iconSize!).isActive = true
            
        }

        
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


