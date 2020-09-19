//
//  MainDrawerViewDelegate.swift
//  bm-persona
//
//  Created by Shawn Huang on 5/1/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

// Drawer delegate to handle stacks of drawers
// Used only for the top-level main drawer that can't be dismissed
protocol MainDrawerViewDelegate: DrawerViewDelegate {
    // all drawers currently being used
    var drawerStack: [DrawerViewDelegate] { get set }
    // positions to return drawers to once they're no longer hidden
    var positions: [DrawerState?] { get set }
    // position to return main drawer to
    var mainDrawerPosition: DrawerState? { get set }
}

extension MainDrawerViewDelegate where Self: UIViewController {
    // get rid of the top drawer entirely
    // if the top drawer is being removed so it can be replaced, showNext should be set to false to prevent the underlying drawer from showing and immediately being covered
    func dismissTop(showNext: Bool = true) {
        if drawerStack.count > 0 {
            let topDrawer = drawerStack.last
            if let topVC = topDrawer!.drawerViewController {
                topVC.removeFromParent()
                topVC.view.removeFromSuperview()
            }
            drawerStack.last!.drawerViewController = nil
            drawerStack.removeLast()
            positions.removeLast()
            // depending on whether the top drawer is being replaced, show the drawer below
            if showNext {
                moveCurrentDrawer(to: (drawerStack.count == 0 ? mainDrawerPosition : positions.last!)!)
            }
        }
    }
    
    // add a new drawer on top of the stack
    func coverTop(newTop: DrawerViewDelegate, newState: DrawerState) {
        self.hideTop()
        drawerStack.append(newTop)
        positions.append(nil)
        moveCurrentDrawer(to: newState)
    }
    
    // hide the top drawer without deleting it, save the last non-hidden position it was in
    func hideTop() {
        if drawerStack.count > 0 {
            var positionBeforeHidden = drawerStack.last!.drawerViewController?.currState
            if positionBeforeHidden == .hidden {
                positionBeforeHidden = drawerStack.last!.drawerViewController?.prevState
            }
            positions[drawerStack.count - 1] = positionBeforeHidden
        } else {
            var positionBeforeHidden = self.drawerViewController?.currState
            if positionBeforeHidden == .hidden {
                positionBeforeHidden = self.drawerViewController?.prevState
            }
            mainDrawerPosition = positionBeforeHidden
        }
        moveCurrentDrawer(to: .hidden)
    }
    
    // show the top drawer again and update the positions list
    func showTop() {
        let movePosition = drawerStack.count == 0 ? mainDrawerPosition : positions.last!
        if movePosition == nil {
            return
        }
        moveCurrentDrawer(to: movePosition!)
        if drawerStack.count > 0 {
            positions[drawerStack.count - 1] = nil
        } else {
            mainDrawerPosition = nil
        }
    }
    
    // move the current top drawer to a specific state
    func moveCurrentDrawer(to state: DrawerState, duration: Double? = nil) {
        if drawerStack.count > 0 {
            let topDrawer = drawerStack.last!
            topDrawer.moveDrawer(to: state, duration: duration)
        } else {
            self.moveDrawer(to: state, duration: duration)
        }
    }
    
    // depending on a pan gesture, return which position to go to
    func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState {
        computePosition(from: yPosition, with: yVelocity, bottom: .collapsed, middle: .middle, top: .full)
    }
}
