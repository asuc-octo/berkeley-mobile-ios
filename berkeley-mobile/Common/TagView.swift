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
        let size = super.sizeThatFits(size)
        return CGSize(
            width: size.width + TagView.kPadding.width,
            height: size.height + TagView.kPadding.height
        )
    }
    
    // MARK: Initializers
    
    init(origin: CGPoint, text: String, color: UIColor) {
        super.init(frame: CGRect.zero)
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)
        defer {
            self.text = text
            self.backgroundColor = color
        }
    }
    
    convenience init() {
        self.init(origin: .zero, text: "", color: .clear)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

// MARK: - Static TagViews

extension TagView {
    
    static var open: TagView {
        return TagView(origin: .zero, text: "Open", color: Color.openTag)
    }
    
    static var closed: TagView {
        // TODO: Check if this should be a different color
        return TagView(origin: .zero, text: "Closed", color: Color.closedTag)
    }
    
}
