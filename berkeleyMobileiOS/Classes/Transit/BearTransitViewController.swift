//
//  BearTransitViewController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/6/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
import GoogleMaps
class BearTransitViewController: UIViewController {
    //Sets up initial tab look for this class
    @IBOutlet weak var mapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 1.285, longitude: 103.848, zoom: 12)
        let MV = GMSMapView.map(withFrame: .zero, camera: camera)
        self.mapView = MV
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
