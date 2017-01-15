//
//  ViewController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 10/9/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
class LaunchViewController: UIViewController {
    @IBOutlet weak var centerYLabel: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.centerYLabel.constant = 0
        UIView.animate(withDuration: 1.2, animations: {
            self.view.layoutIfNeeded()
        })
        _ = Timer.scheduledTimer(timeInterval: 2, target:self, selector: #selector(LaunchViewController.presentMainViewController), userInfo: nil, repeats: false)

    }
    //After launch animation, present the actual workflow. All tabs should be in this init statement.
    func presentMainViewController() {
        let indexViewController: UIViewController  = TabBarController(viewControllers: [
                UIStoryboard.viewController(identifier: "recreationNav") as! RecreationNavigationController, 
                UIStoryboard.viewController(identifier: "academicsNav") as! AcademicsNavigationController,
                UIStoryboard(name: "Dining", bundle: nil).instantiateInitialViewController()!,
                UIStoryboard.viewController(identifier: "beartransitNav") as! BearTransitNavigationController
            ], selectedIndex: 0)
        indexViewController.modalTransitionStyle = .crossDissolve
        self.present(indexViewController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

