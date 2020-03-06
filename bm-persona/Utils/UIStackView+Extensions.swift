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
    public func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
