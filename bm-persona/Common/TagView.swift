//
//  TagView.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/8/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class TagView: UILabel {

    static let kPadding: CGSize = CGSize(width: 20, height: 5)
    static let kFont: UIFont = Font.semibold(10)
    static let kTextColor: UIColor = .white
    
    override var text: String? {
        didSet {
            font = TagView.kFont
            textColor = TagView.kTextColor
            textAlignment = .center
            
            sizeToFit()
            layer.cornerRadius = frame.height / 2
            layer.masksToBounds = true
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + TagView.kPadding.width,
            height: size.height + TagView.kPadding.height
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    init(origin: CGPoint, text: String, color: UIColor) {
        super.init(frame: CGRect.zero)
        defer {
            self.text = text
            self.backgroundColor = color
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}