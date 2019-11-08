//
//  Extensions.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var heightConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
    }

    var widthConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
    }
   
    public func addSubViews(_ views: [UIView]) {
        views.forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
    }
    
    public func centerSubView(_ view: UIView) {
        self.addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)]
        )
    }
    
    public func setConstraintsToView(top: UIView? = nil, tConst: CGFloat = 0,
                                     bottom: UIView? = nil, bConst: CGFloat = 0,
                                     left: UIView? = nil, lConst: CGFloat = 0,
                                     right: UIView? = nil, rConst: CGFloat = 0) {
        guard let suView = self.superview else { return }
        // Set top constraints if the view is specified.
        if let top = top {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .top,
                                   relatedBy: .equal,
                                   toItem: top, attribute: .top,
                                   multiplier: 1.0, constant: tConst)
            )
        }
        // Set bottom constraints if the view is specified.
        if let bottom = bottom {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: bottom, attribute: .bottom,
                                   multiplier: 1.0, constant: bConst)
            )
        }
        // Set left constraints if the view is specified.
        if let left = left {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .left,
                                   relatedBy: .equal,
                                   toItem: left, attribute: .left,
                                   multiplier: 1.0, constant: lConst)
            )
        }
        // Set right constraints if the view is specified.
        if let right = right {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .right,
                                   relatedBy: .equal,
                                   toItem: right, attribute: .right,
                                   multiplier: 1.0, constant: rConst)
            )
        }
    }

    public func setHeightConstraint(_ height: CGFloat) {
        if self.heightConstraint != nil {
            self.heightConstraint?.isActive = false
        }
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height).isActive = true
    }
    
    public func setWidthConstraint(_ width: CGFloat) {
        if self.widthConstraint != nil {
            self.widthConstraint?.isActive = false
        }
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width).isActive = true
    }
}

// MARK: - UIImage
extension UIImage {
    public func colored(_ color: UIColor?) -> UIImage? {
        if let newColor = color {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
          
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
           
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)
            newColor.setFill()
            context.fill(rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            newImage.accessibilityIdentifier = accessibilityIdentifier
            return newImage
        }
        return self
    }
}
