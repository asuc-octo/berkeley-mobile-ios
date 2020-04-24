//
//  MainContainerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class MainContainerViewController: UIViewController, DrawerViewDelegate {
    let mapViewController = MapViewController()
    
    var drawerViewController: DrawerViewController? = MainDrawerViewController()
    var initialDrawerCenter = CGPoint()
    var drawerStatePositions: [DrawerState: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let drawerVC = drawerViewController as! MainDrawerViewController
        add(child: mapViewController)
        add(child: drawerVC)
        drawerVC.delegate = self
        mapViewController.view.frame = self.view.frame
        mapViewController.drawerContainer = self
        drawerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawerVC.view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            drawerVC.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            drawerVC.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            drawerVC.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: self.view.frame.maxY * 0.9)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawerStatePositions[.hidden] = self.view.frame.maxY + (self.view.frame.maxY / 2)
        drawerStatePositions[.collapsed] = self.view.frame.maxY * 0.9 + (self.view.frame.maxY / 2)
        drawerStatePositions[.middle] = self.view.frame.midY * 1.1 + (self.view.frame.maxY / 2)
        drawerStatePositions[.full] = self.view.safeAreaInsets.top + (self.view.frame.maxY / 2)
        (drawerViewController as! MainDrawerViewController).heightOffset = self.view.safeAreaInsets.top
        self.initialDrawerCenter = drawerViewController!.view.center
        moveDrawer(to: drawerViewController!.state, duration: 0)
    }

}

// for main drawer view
extension MainContainerViewController {
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
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
        } else {
            self.drawerViewController!.view.center = newCenter
        }
    }
    
    private func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState {
        computePosition(from: yPosition, with: yVelocity, bottom: .collapsed, middle: .middle, top: .full)
    }
}
