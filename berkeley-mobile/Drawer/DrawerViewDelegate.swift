//
//  DrawerViewDelegate.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

enum DrawerState {
    case hidden
    case collapsed
    case middle
    case full
}

/// Handles all moving of drawers and user gestures related to drawers
protocol DrawerViewDelegate: class {
    func handlePanGesture(gesture: UIPanGestureRecognizer)
    func moveDrawer(to state: DrawerState, duration: Double?)
    /// set the drawer to a preset position based on user's panning gesture
    func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState
    
    /// center of detail view before position changes
    var initialDrawerCenter: CGPoint { get set }
    /// dictionary of all positions to corresponding center-y values
    var drawerStatePositions: [DrawerState: CGFloat] { get set }
    /// the drawer being controlled by this delegate
    var drawerViewController: DrawerViewController? { get set }
}

extension DrawerViewDelegate {
    /// moves this delegate's drawer to a position
    func moveDrawer(to state: DrawerState, duration: Double? = nil) {
        guard let drawerViewController = self.drawerViewController, var position = drawerStatePositions[state] else { return }
        var moveState = state
        if let upperLimitState = drawerViewController.upperLimitState,
           let upperLimitPosition = drawerStatePositions[upperLimitState],
           position < upperLimitPosition {
            position = upperLimitPosition
            moveState = upperLimitState
        }
        let moveDuration = duration ?? (moveState == .full ? 0.6 : 0.5)
        UIView.animate(withDuration: moveDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.5, options: .curveEaseOut, animations: {
            // save last non-hidden position in prevState
            if drawerViewController.currState != .hidden {
                drawerViewController.prevState = drawerViewController.currState
            }
            drawerViewController.currState = state
            drawerViewController.view.center = CGPoint(x: self.initialDrawerCenter.x, y: position)
        })
    }
    
    /// choose between three set positions (bottom, middle, top) based on pan gesture
    func computePosition(from yPosition: CGFloat, with yVelocity: CGFloat, bottom: DrawerState, middle: DrawerState, top: DrawerState) -> DrawerState {
        guard let hiddenPos = drawerStatePositions[bottom], let middlePos = drawerStatePositions[middle], let fullPos = drawerStatePositions[top] else { return .middle }
        
        let betweenBottom = (hiddenPos + middlePos) / 2
        let betweenTop = (middlePos + fullPos) / 2
        
        if yPosition > betweenBottom {
            if yVelocity < -800 {
                return middle
            } else {
                return bottom
            }
        } else if yPosition > betweenTop {
            if yVelocity > 800 {
                return bottom
            } else if yVelocity < -800 {
                return top
            } else {
                return middle
            }
        } else if yVelocity > 800 {
            return middle
        } else {
            return top
        }
    }
}

extension DrawerViewDelegate where Self: UIViewController {
    /// default version of handling pan that returns the new state of the drawer
    @discardableResult func handlePan(gesture: UIPanGestureRecognizer) -> DrawerState {
        guard let drawerViewController = self.drawerViewController else { return .middle }
        if gesture.state == .began {
            initialDrawerCenter = drawerViewController.view.center
        }
        
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view).y
        var newCenter = CGPoint(x: self.initialDrawerCenter.x, y: self.initialDrawerCenter.y + translation.y)
        
        // prevent the view from going off the top of the screen
        if let upperLimitState = drawerViewController.upperLimitState, let centerLimit = drawerStatePositions[upperLimitState] {
            if newCenter.y < centerLimit {
                newCenter.y = centerLimit
            }
        } else if newCenter.y < drawerViewController.view.frame.height / 2 {
            newCenter.y = drawerViewController.view.frame.height / 2
        }
        
        // lock to a preset position if user stops panning
        if gesture.state == .ended {
            let drawerState = computeDrawerPosition(from: newCenter.y, with: velocity)
            guard let position = drawerStatePositions[drawerState] else { return .middle }
            let pixelDiff = abs(newCenter.y - position)
            var animationTime = pixelDiff / abs(velocity)
            
            if pixelDiff / animationTime < 300 {
                animationTime = pixelDiff / 300
            } else if pixelDiff / animationTime > 700 {
                animationTime = pixelDiff / 700
            }
            moveDrawer(to: drawerState, duration: Double(animationTime))
            return drawerState
        } else {
            // otherwise follow the motion of the pan
            drawerViewController.view.center = newCenter
            return .middle
        }
    }
}
