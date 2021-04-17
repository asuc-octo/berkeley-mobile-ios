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
        drawerViewController.shouldHandlePan = false
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:
            #selector(determineActiveGestureRecognizer(gesture:)))
        panGestureRecognizer.delegate = self
        drawerViewController.view.addGestureRecognizer(panGestureRecognizer)
    }

    /// The content offset at the start of the gesture, if any.
    var initialOffset: CGPoint?

    /// Activates or deactivates the drawer's gesture recognizer and the scrollview's gesture
    /// recognizer, depending on which one should be used for the given gesture.
    @objc func determineActiveGestureRecognizer(gesture: UIPanGestureRecognizer) {
        guard let drawerViewController = drawerViewController else { return }
        if gesture.state == .began || gesture.state == .changed {
            // Boolean indicating if the user is swiping upwards
            let offset = gesture.translation(in: drawerViewController.view).y
            // Hardcoded threshold for ambiguity
            let ambiguousPan = abs(offset) < 1
            let panUp = offset < 0
            // Pan the drawer when the scrollview reaches the top or bottom, or if the drawer is not expanded
            let shouldPanDrawer = !ambiguousPan &&
                (!panUp && isAtTop ||
                panUp && isAtBottom ||
                drawerViewController.currState != .full)
            isScrollEnabled = !shouldPanDrawer
            drawerViewController.shouldHandlePan = shouldPanDrawer
            initialOffset = gesture.state == .began ? contentOffset : initialOffset
        } else if gesture.state == .ended {
            isScrollEnabled = true
            drawerViewController.shouldHandlePan = false
            // If only the drawer has been moved, don't block the drawer gesture handler.
            if initialOffset == nil || initialOffset == contentOffset {
                drawerViewController.delegate?.handlePanGesture(gesture: gesture)
            }
            initialOffset = nil
        }
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        // Drags that start from a button hold (or other similar controls) should still scroll the view.
        if view is UIControl &&
            !(view is UITextInput) &&
            !(view is UISlider) &&
            !(view is UISwitch) {
            return true
        }
        return super.touchesShouldCancel(in: view)
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
        return contentOffset.y == -topInset
    }

    var isAtBottom: Bool {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return contentOffset.y == scrollViewBottomOffset
    }
}
