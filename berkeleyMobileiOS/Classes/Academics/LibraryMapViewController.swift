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
import GoogleMaps

class LibraryMapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var librariesTableView: UITableView!

    @IBOutlet var librariesMapView: GMSMapView!
    
    var libraries = [CLLocation(latitude: 37.871856, longitude: -122.258423),
        CLLocation(latitude: 37.872545, longitude: -122.256423)
                     ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        librariesMapView.delegate = self
        librariesMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 12)
        self.librariesMapView.camera = camera
        self.librariesMapView.frame = self.view.frame

        plotLibraries()
        
        // Do any additional setup after loading the view.
    }
    
    func plotLibraries() {
        
        for library in libraries {
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: library.coordinate.latitude, longitude: library.coordinate.longitude)
            marker.title = "Sydney"
            marker.snippet = "Australia"
            
            marker.map = self.librariesMapView
        
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchToList(_ sender: Any) {
        self.performSegue(withIdentifier: "mapToList", sender: self)
        
    }
    
    
    @IBAction func dismissMap(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    


}
