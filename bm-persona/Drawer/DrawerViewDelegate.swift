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

protocol DrawerViewDelegate: class {
    func handlePanGesture(gesture: UIPanGestureRecognizer)
    func moveDrawer(to state: DrawerState, duration: Double)
    func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState
    
    var initialDrawerCenter: CGPoint { get set }
    var drawerStatePositions: [DrawerState: CGFloat] { get set }
    var drawerViewController: DrawerViewController? { get set }
}

extension DrawerViewDelegate where Self: UIViewController {
    
    func moveDrawer(to state: DrawerState, duration: Double) {
        if drawerViewController == nil {
            return
        }
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            print(self.drawerViewController)
            print(self.drawerViewController!.view.center)
            self.drawerViewController!.view.center = CGPoint(x: self.initialDrawerCenter.x, y: self.drawerStatePositions[state]!)
            print(self.drawerViewController!.view.center)
        }, completion: { success in
            if success {
                if state != .hidden {
                    self.drawerViewController!.state = state
                }
                // TODO: why does this fix it?
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.drawerViewController!.view.center = CGPoint(x: self.initialDrawerCenter.x, y: self.drawerStatePositions[state]!)
                })
            }
        })
    }
    
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
    
    @discardableResult func handlePan(gesture: UIPanGestureRecognizer) -> DrawerState {
        if gesture.state == .began {
            initialDrawerCenter = drawerViewController!.view.center
        }
        
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view).y
        var newCenter = CGPoint(x: self.initialDrawerCenter.x, y: self.initialDrawerCenter.y + translation.y)
        
        if newCenter.y < self.view.center.y {
            newCenter = self.view.center
        }
        
        if gesture.state == .ended {
            let drawerState = computeDrawerPosition(from: newCenter.y, with: velocity)
            let pixelDiff = abs(newCenter.y - drawerStatePositions[drawerState]!)
            var animationTime = pixelDiff / abs(velocity)
            
            if pixelDiff / animationTime < 300 {
                animationTime = pixelDiff / 300
            } else if pixelDiff / animationTime > 700 {
                animationTime = pixelDiff / 700
            }
            moveDrawer(to: drawerState, duration: Double(animationTime))
            return drawerState
        } else {
            self.drawerViewController!.view.center = newCenter
            return .middle
        }
    }
}
