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
    
    private var mapView: MKMapView!
    private var searchBar: SearchBarView!
    private var dim: CGSize = .zero
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dim = self.view.frame.size
        
        mapView = MKMapView()
        searchBar = SearchBarView()
        
        requestLocation()
        
        self.view.addSubViews([mapView, searchBar])
    }
    
    override func viewDidLayoutSubviews() {
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        
        self.view.addConstraints([
        NSLayoutConstraint(item: searchBar as Any, attribute: .top,
                           relatedBy: .equal,
                           toItem: self.view, attribute: .top,
                           multiplier: 1.0, constant: 0.1*self.dim.height),
        NSLayoutConstraint(item: searchBar as Any, attribute: .centerX,
                           relatedBy: .equal,
                           toItem: self.view, attribute: .centerX,
                           multiplier: 1.0, constant: 0.0)
        ])
        
        searchBar.setHeightConstraint(0.07*dim.height)
        searchBar.setWidthConstraint(0.9*dim.width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        (mapView.isZoomEnabled, mapView.showsUserLocation) = (true, true)
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func requestLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: ", error)
    }
}


