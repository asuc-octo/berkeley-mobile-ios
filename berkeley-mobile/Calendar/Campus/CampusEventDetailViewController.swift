//
//  CampusWideEventDetailViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 9/19/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class CampusEventDetailViewController: UIViewController {
    
    var barView: BarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpBackgroundView()
    }
    
    func setUpBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        
        barView = BarView(superViewWidth: view.frame.width)
        view.addSubview(barView)
    }

}
