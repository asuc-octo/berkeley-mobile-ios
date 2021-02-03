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

    init(title: String, font: UIFont = Font.medium(12), defaultColor: UIColor = Color.ActionButton.background, pressedColor: UIColor = Color.ActionButton.highlighted) {
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
        label.textColor = Color.ActionButton.color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
