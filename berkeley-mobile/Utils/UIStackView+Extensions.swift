//
//  UIStackView+Extensions.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {

    /// Returns `true` iff the stack view has no children or if all those children are hidden.
    public var emptyOrChildrenHidden: Bool {
        return arrangedSubviews.isEmpty || arrangedSubviews.allSatisfy { $0.isHidden }
    }

    public func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
