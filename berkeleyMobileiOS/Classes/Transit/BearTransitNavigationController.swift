//
//  BearTransitNavigationController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/17/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class BearTransitNavigationController: UINavigationController, IBInitializable {

    // MARK: - IBInitializable
    typealias IBObjectType = BearTransitNavigationController
    
    static func fromIB() -> IBObjectType {
        return UIStoryboard.transit.instantiateViewController(withIdentifier: className(IBObjectType.self)) as! IBObjectType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Page Tab Bar
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    //Customize Tab Bar Presence
    private func preparePageTabBarItem() {
        pageTabBarItem.image = #imageLiteral(resourceName: "50x50-BearTransit_32x32")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    //Make sure tab bar is highlighted properly
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
        self.navigationBar.isHidden = true;
    }
    
}
