//
//  MainDrawerViewDelegate.swift
//  bm-persona
//
//  Created by Shawn Huang on 5/1/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

protocol MainDrawerViewDelegate: DrawerViewDelegate {
    var drawerStack: [DrawerViewDelegate] { get set }
    var positions: [DrawerState?] { get set }
    var mainDrawerPosition: DrawerState? { get set }
}

extension MainDrawerViewDelegate {
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
            if showNext {
                moveCurrentDrawer(to: (drawerStack.count == 0 ? mainDrawerPosition : positions.last!)!, duration: 0.2)
            }
        }
    }
    
    func coverTop(newTop: DrawerViewDelegate, newState: DrawerState) {
        self.hideTop()
        drawerStack.append(newTop)
        positions.append(nil)
        moveCurrentDrawer(to: newState, duration: 0.2)
    }
    
    func hideTop() {
        if drawerStack.count > 0 {
            let positionBeforeHidden = drawerStack.last!.drawerViewController?.state
            positions[drawerStack.count - 1] = positionBeforeHidden
        } else {
            mainDrawerPosition = self.drawerViewController?.state
        }
        moveCurrentDrawer(to: .hidden, duration: 0.2)
    }
    
    func showTop() {
        let movePosition = drawerStack.count == 0 ? mainDrawerPosition : positions.last!
        if movePosition == nil {
            return
        }
        moveCurrentDrawer(to: movePosition!, duration: 0.2)
        if drawerStack.count > 0 {
            positions[drawerStack.count - 1] = nil
        } else {
            mainDrawerPosition = nil
        }
    }
    
    func moveCurrentDrawer(to state: DrawerState, duration: Double) {
        if drawerStack.count > 0 {
            let topDrawer = drawerStack.last!
            topDrawer.moveDrawer(to: state, duration: duration)
        } else {
            self.moveDrawer(to: state, duration: duration)
        }
    }
    
}
