//
//  UIViewController+Extensions.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/4/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public func add(child: UIViewController, frame: CGRect = .zero) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = frame
        child.didMove(toParent: self)
    }
    
    public func add(child: UIViewController, toView view: UIView, frame: CGRect = .zero) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = frame
        child.didMove(toParent: self)
    }
    
    // Presents an alert with multiple options and completion handler
    public func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            if (index == 0) {
                alertController.addAction(UIAlertAction.init(title: option, style: .cancel, handler: { (action) in
                    completion(index)
                }))
            } else {
                alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                    completion(index)
                }))
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
