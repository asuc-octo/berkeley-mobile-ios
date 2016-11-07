//
//  DiningHallViewController.swift
//  berkeleyMobileiOS
//
//  Created by Bohui Moon on 11/6/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material

class DiningHallViewController: UIViewController
{
    // Data
    var diningHall: DiningHall? = nil
    
    // UI
    var backdrop: UIImageView = UIImageView()
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    func backPressed()
    {
        
    }
}
