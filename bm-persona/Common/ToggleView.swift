//
//  ToggleView.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class ToggleView: UILabel {

    static let kPadding: CGSize = CGSize(width: 30, height: 15)
    static let kFont: UIFont = Font.semibold(15)
    static let unselectedTextColor: UIColor = .black
    static let selectedTextColor: UIColor = .white
    static let unselectedBgColor: UIColor = .white
    static let selectedBgColor: UIColor = .red
    var on = false
    
    override var text: String? {
        didSet {
            font = ToggleView.kFont
            textColor = ToggleView.unselectedTextColor
            textAlignment = .center
            backgroundColor = ToggleView.unselectedBgColor
            setCornerBorder(color: .black, cornerRadius: frame.height / 2, borderWidth: 0.5)
            
            sizeToFit()
            layer.cornerRadius = frame.height / 2
            layer.masksToBounds = true
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + ToggleView.kPadding.width,
            height: size.height + ToggleView.kPadding.height
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    init(origin: CGPoint, text: String) {
        super.init(frame: CGRect.zero)
        defer {
            self.text = text
        }
        self.isUserInteractionEnabled = true
    }
    
    func toggle() {
        on = !on
        if on {
            textColor = ToggleView.selectedTextColor
            backgroundColor = ToggleView.selectedBgColor
        } else {
            textColor = ToggleView.unselectedTextColor
            backgroundColor = ToggleView.unselectedBgColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
