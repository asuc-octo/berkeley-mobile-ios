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
    var barView: UIView = UIView()
    
    // maximum upper position to limit the drawer to (or nil if limit is top of screen)
    var upperLimitState: DrawerState? {
        get { return nil }
    }
    
    static var bottomOffsetY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // default to collapsed initial position
        currState = .collapsed
        prevState = .collapsed
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: DrawerViewController.bottomOffsetY + 20, right: 16)
        
        setupBackgroundView()
        setupGestures()
    }
    
    func setupBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        
        barView = UIView(frame: CGRect(x: self.view.frame.width / 2 - self.view.frame.width / 30, y: 7, width: self.view.frame.width / 15, height: 5))
        barView.backgroundColor = .lightGray
        barView.alpha = 0.5
        barView.layer.cornerRadius = barView.frame.height / 2
        barView.clipsToBounds = true
        view.addSubview(barView)
    }
    
    func setupGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        delegate.handlePanGesture(gesture: gesture)
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
