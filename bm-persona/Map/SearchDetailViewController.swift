//
//  SearchDetailView.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/21/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

import UIKit

enum SearchDetailState {
    case middle
    case full
    case hidden
}

protocol SearchDetailViewDelegate {
    func handlePanGesture(gesture: UIPanGestureRecognizer)
}

class SearchDetailViewController: UIViewController {
    var delegate: SearchDetailViewDelegate!
    var state: SearchDetailState = .middle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setupBarView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        let barView = UIView(frame: CGRect(x: self.view.frame.width / 2 - self.view.frame.width / 30, y: 7, width: self.view.frame.width / 15, height: 5))
        print(barView.frame)
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
