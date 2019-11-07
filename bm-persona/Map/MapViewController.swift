//
//  ViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.bounds = self.view.bounds
        self.view = mapView
        configureMapView()
    }
    
    func configureMapView() {
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.8719, longitude: 122.2585), latitudinalMeters: CLLocationDistance(exactly: 10)!, longitudinalMeters: CLLocationDistance(exactly: 10)!), animated: true)
    }
    
  
    


}

