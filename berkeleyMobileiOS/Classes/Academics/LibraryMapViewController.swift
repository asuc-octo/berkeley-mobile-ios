//
//  LibraryMapViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/17/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LibraryMapViewController: UIViewController {
    
    @IBOutlet var librariesTableView: UITableView!
    @IBOutlet var librariesMapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toListView(_ sender: Any) {
        
        self.performSegue(withIdentifier: "mapToList", sender: self)
    }


}
