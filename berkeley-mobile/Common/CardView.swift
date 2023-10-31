//
//  CardView.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/8/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = BMColor.cardBackground
        layer.cornerRadius = 12
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
    }
    
    /* Shamelessly stolen from:
     * stackoverflow.com/questions/43944020/animating-calayer-shadow-simultaneously-as-uitableviewcell-height-animates
     * Implicitly animates shadowPath. */
    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        guard event == "shadowPath" else {
            return super.action(for: layer, forKey: event)
        }

        guard let priorPath = layer.shadowPath else {
            return super.action(for: layer, forKey: event)
        }

        guard let sizeAnimation = layer.animation(forKey: "bounds.size") as? CABasicAnimation else {
            return super.action(for: layer, forKey: event)
        }

        let animation = sizeAnimation.copy() as! CABasicAnimation
        animation.keyPath = "shadowPath"
        let action = ShadowingViewAction()
        action.priorPath = priorPath
        action.pendingAnimation = animation
        return action
    }

}

private class ShadowingViewAction: NSObject, CAAction {
    var pendingAnimation: CABasicAnimation? = nil
    var priorPath: CGPath? = nil

    // CAAction Protocol
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
        guard let layer = anObject as? CALayer, let animation = self.pendingAnimation else {
            return
        }

        animation.fromValue = self.priorPath
        animation.toValue = layer.shadowPath
        layer.add(animation, forKey: "shadowPath")
    }
}
