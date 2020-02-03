//
//  MainContainerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

protocol DrawerViewDelegate {
    func handlePanGesture(gesture: UIPanGestureRecognizer)
    func searchInitiated()
}


class MainContainerViewController: UIViewController {
    let mapViewController = MapViewController()
    let drawerViewController = DrawerViewController()
    
    var initialDrawerCenter = CGPoint()
    var drawerStatePositions: [DrawerState: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add(child: mapViewController)
        add(child: drawerViewController)
        
        drawerViewController.delegate = self
        mapViewController.view.frame = self.view.frame
        
        drawerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawerViewController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            drawerViewController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            drawerViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            drawerViewController.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: self.view.frame.maxY * 0.9)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawerStatePositions[.collapsed] = self.view.frame.maxY * 0.9 + (self.view.frame.maxY / 2)
        drawerStatePositions[.middle] = self.view.frame.midY * 1.1 + (self.view.frame.maxY / 2)
        drawerStatePositions[.full] = self.view.safeAreaInsets.top + (self.view.frame.maxY / 2)
        self.initialDrawerCenter = drawerViewController.view.center
        moveDrawer(to: drawerViewController.state, duration: 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func moveDrawer(to state: DrawerState, duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.drawerViewController.view.center = CGPoint(x: self.initialDrawerCenter.x, y: self.drawerStatePositions[state]!)
        }, completion: { success in
            if success {
                self.drawerViewController.state = state
            }
        })
    }

}

extension MainContainerViewController: DrawerViewDelegate {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            self.initialDrawerCenter = drawerViewController.view.center
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
            self.drawerViewController.view.center = newCenter
        }
        
        
    }
    
    func searchInitiated() {
        moveDrawer(to: .full, duration: 0.5)
    }
    
    private func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState {
        guard let collapsedPos = drawerStatePositions[DrawerState.collapsed], let middlePos = drawerStatePositions[DrawerState.middle], let fullPos = drawerStatePositions[DrawerState.full] else { return .collapsed }
        
        let betweenBottom = (collapsedPos + middlePos) / 2
        let betweenTop = (middlePos + fullPos) / 2
        
        if yPosition > betweenBottom {
            if yVelocity < -800 {
                return .middle
            } else {
                return .collapsed
            }
        } else if yPosition > betweenTop {
            if yVelocity > 800 {
                return .collapsed
            } else if yVelocity < -800 {
                return .full
            } else {
                return .middle
            }
        } else if yVelocity > 800 {
            return .middle
        } else {
            return .full
        }
    }
}

extension UIViewController {
    func add(child: UIViewController) {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
