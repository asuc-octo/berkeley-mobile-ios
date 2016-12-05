//
//  LibrariesListViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/13/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class LibrariesListViewController: UIViewController {
    
    @IBOutlet var librariesTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchMapView(_ sender: Any) {
        
        self.performSegue(withIdentifier: "listToMap", sender: self)
    }

    @IBAction func switchMap(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func returnList(_ sender: Any) {
        
//        let vc = AcademicsViewController()
        
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

        
        
        
    }

}
