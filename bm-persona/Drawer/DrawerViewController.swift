//
//  DrawerViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

enum DrawerState {
    case collapsed
    case middle
    case full
}

class DrawerViewController: UIViewController {
    var delegate: DrawerViewDelegate!
    var state: DrawerState = .collapsed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupBackgroundView()
        setupGestures()
    }
    
    func setupBackgroundView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 10
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
        tabBarViewController.view.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
        
//        NSLayoutConstraint.activate([
//            tabBarViewController.view.topAncher.constraint(equalTo: searchTextField.bottomAncher),
//            tabBarViewController.view.leadingAncher.constraint(equalTo: self.view.leadingAncher),
//        ])
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
