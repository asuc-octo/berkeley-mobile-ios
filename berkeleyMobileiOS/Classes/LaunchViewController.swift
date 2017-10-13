//
//  ViewController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 10/9/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
class LaunchViewController: UIViewController 
{
    @IBOutlet weak var centerYLabel: NSLayoutConstraint!
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.centerYLabel.constant = 0
        UIView.animate(withDuration: 1.2, animations: {
            self.view.layoutIfNeeded()
        })
//        _ = Timer.scheduledTimer(timeInterval: 2, target:self, selector: #selector(LaunchViewController.presentMainViewController), userInfo: nil, repeats: false)
    }
    
    //After launch animation, present the actual workflow. All tabs should be in this init statement.

}

