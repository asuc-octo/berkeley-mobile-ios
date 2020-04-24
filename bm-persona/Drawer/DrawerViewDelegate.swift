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

protocol DrawerViewDelegate {
    func handlePanGesture(gesture: UIPanGestureRecognizer)
    func moveDrawer(to state: DrawerState, duration: Double)
    
    var initialDrawerCenter: CGPoint { get set }
    var drawerStatePositions: [DrawerState: CGFloat] { get set }
    var drawerViewController: DrawerViewController? { get }
}

extension DrawerViewDelegate where Self: UIViewController {
    
    func moveDrawer(to state: DrawerState, duration: Double) {
        if drawerViewController == nil {
            return
        }
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.drawerViewController!.view.center = CGPoint(x: self.initialDrawerCenter.x, y: self.drawerStatePositions[state]!)
        }, completion: { success in
            if success {
                self.drawerViewController!.state = state
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
    
}
