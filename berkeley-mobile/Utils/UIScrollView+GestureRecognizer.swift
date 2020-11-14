//
//  UIScrollView+GestureRecognizer.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/17/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

// MARK: - SimultaneousGestureScrollView

/// A `UIScrollView` that can be scrolled simultaneously with gesture recognizers in superviews or subviews.
/// Intended to be used within a `DrawerViewController`.
class SimultaneousGestureScrollView: UIScrollView, UIGestureRecognizerDelegate {

    /// A drawer containing this scrollview, if it exists.
    ///
    /// This value must be non-nil to use `setupDummyGesture` and `determineActiveGestureRecognizer`.
    weak var drawerViewController: DrawerViewController?

    /// Adds a gesture recognizer that determines if a pan should be handled by the drawer or by the scrollview.
    func setupDummyGesture() {
        guard let drawerViewController = drawerViewController else { return }
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:
            #selector(determineActiveGestureRecognizer(gesture:)))
        panGestureRecognizer.delegate = self
        drawerViewController.view.addGestureRecognizer(panGestureRecognizer)
    }

    /// Activates or deactivates the drawer's gesture recognizer and the scrollview's gesture
    /// recognizer, depending on which one should be used for the given gesture.
    @objc func determineActiveGestureRecognizer(gesture: UIPanGestureRecognizer) {
        guard let drawerViewController = drawerViewController else { return }
        guard gesture.state == .began || gesture.state == .ended else { return }
        if gesture.state == .began {
            // Boolean indicating if the user is swiping upwards
            let panUp = gesture.translation(in: drawerViewController.view).y < 0
            // Pan the drawer when the scrollview reaches the top or bottom, or if the drawer is not expanded
            let shouldPanDrawer = !panUp && isAtTop ||
                panUp && isAtBottom ||
                drawerViewController.currState != .full
            isScrollEnabled = !shouldPanDrawer
            drawerViewController.panGestureRecognizer.isEnabled = shouldPanDrawer
            // Reset the drawer position, since it may have moved before the gesture state became .began
            if !shouldPanDrawer {
                drawerViewController.delegate.moveDrawer(to: drawerViewController.currState, duration: 0)
            }
        } else {
            isScrollEnabled = true
            drawerViewController.panGestureRecognizer.isEnabled = true
        }
    }

    // MARK: UIScrollViewDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return drawerViewController != nil
    }
}

// MARK: - UIScrollView Extensions

extension UIScrollView {

    var isAtTop: Bool {
        let topInset = contentInset.top
        return contentOffset.y <= -topInset
    }

    var isAtBottom: Bool {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return contentOffset.y >= scrollViewBottomOffset
    }
}
