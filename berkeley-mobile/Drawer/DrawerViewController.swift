//
//  DrawerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

// General drawer with a gray bar at the top, can handle pan gesture to change position
class DrawerViewController: UIViewController {
    var delegate: DrawerViewDelegate!
    
    // the current position of the drawer
    var currState: DrawerState!
    
    // the last non-hidden position of the drawer (used to return drawer to correct position if it's currently hidden/covered)
    var prevState: DrawerState!
    var barView: BarView!
    
    // maximum upper position to limit the drawer to (or nil if limit is top of screen)
    var upperLimitState: DrawerState? {
        get { return nil }
    }

    // The gesture recognizer that handles movement of this drawer
    var panGestureRecognizer: UIPanGestureRecognizer!
    // Indicates whether or not the drawer should respond to the recognized gesture.
    var shouldHandlePan: Bool! = true {
        didSet {
            if let delegate = delegate as? UIViewController & DrawerViewDelegate {
                delegate.initialGestureTranslation = panGestureRecognizer.translation(in: delegate.view)
                delegate.initialDrawerCenter = view.center
            }
        }
    }
    
    static var bottomOffsetY: CGFloat = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // default to middle initial position
        currState = .middle
        prevState = .middle
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: DrawerViewController.bottomOffsetY + 20, right: 16)
        
        setupBackgroundView()
        setupGestures()
    }

    func setupBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        
        barView = BarView(superViewWidth: view.frame.width)
        view.addSubview(barView)
    }
    
    func setupGestures() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard shouldHandlePan else { return }
        delegate.handlePanGesture(gesture: gesture)
    }

}
