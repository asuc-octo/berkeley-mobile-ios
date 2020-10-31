//
//  BarView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 9/19/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

/// Gray bar to indicate that a view can be pulled
class BarView: UIView {
    /// Initialize with superview width so that bar is proportional to superview
    init(superViewWidth: CGFloat) {
        super.init(frame: CGRect.zero)
        self.frame = defaultFrame(superViewWidth: superViewWidth)
        self.backgroundColor = .lightGray
        self.alpha = 0.5
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    func defaultFrame(superViewWidth: CGFloat) -> CGRect {
        return CGRect(x: superViewWidth / 2 - superViewWidth / 30, y: 7, width: superViewWidth / 15, height: 5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
