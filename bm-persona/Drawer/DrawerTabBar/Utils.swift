//
//  Utils.swift
//  TabBarPoC
//
//  Created by Kevin Hu on 10/25/19.
//  Copyright © 2019 hu. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIImage

extension UIImage {

    func resized(size: CGSize)-> UIImage{
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}


// MARK: - UIViewController

extension UIViewController {
    
    func add(child: UIViewController, frame: CGRect) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = frame
        child.didMove(toParent: self)
    }
    
    func add(child: UIViewController, toView view: UIView, frame: CGRect) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = frame
        child.didMove(toParent: self)
    }
    
}
