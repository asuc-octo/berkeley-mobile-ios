//
//  DrawerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

enum DrawerState {
    case hidden
    case collapsed
    case middle
    case full
}

class DrawerViewController: UIViewController {
    var delegate: DrawerViewDelegate!
    var state: DrawerState = .collapsed
    var bInitialized: Bool = false
    var heightOffset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !bInitialized {
            setupBackgroundView()
            setupGestures()
            bInitialized = true
        }
    }
    
    func setupBackgroundView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.modalBackground
        
        backgroundView.layer.cornerRadius = 50
        backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        backgroundView.clipsToBounds = true
        
        let barView = UIView(frame: CGRect(x: self.view.frame.width / 2 - self.view.frame.width / 30, y: 7, width: self.view.frame.width / 15, height: 5))
        barView.backgroundColor = .lightGray
        barView.alpha = 0.5
        barView.layer.cornerRadius = barView.frame.height / 2
        barView.clipsToBounds = true
        backgroundView.addSubview(barView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view = backgroundView
        
        let tabBarViewController = TabBarViewController()
        self.add(child: tabBarViewController)
        tabBarViewController.view.frame = self.view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: (heightOffset ?? 0) + 20, right: 0))
        tabBarViewController.view.frame.origin.y = barView.frame.maxY + 16
        tabBarViewController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func setupGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        delegate.handlePanGesture(gesture: gesture)
    }
    
    @objc func editingBegan() {
        delegate.searchInitiated()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
