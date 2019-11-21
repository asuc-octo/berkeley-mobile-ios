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
    private var searchResultsView: SearchResultsView!
    private var dim: CGSize = .zero
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dim = self.view.frame.size
        
        mapView = MKMapView()
        
        searchBar = SearchBarView(
            onStartSearch: { [weak self] (isSearching) in
                guard let self = self else { return }
                self.showSearchResultsView(isSearching)
            }, onClearInput: { [weak self] in
                guard let self = self else { return }
                self.searchResultsView.state = .populated([])
            }, delegate: self
        )
        
        searchResultsView = SearchResultsView()
        showSearchResultsView(false)
        
        requestLocation()
        
        self.view.addSubViews([mapView, searchResultsView, searchBar])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        
        self.view.addConstraints([
            NSLayoutConstraint(item: searchBar as Any, attribute: .top,
                           relatedBy: .equal,
                           toItem: self.view, attribute: .top,
                           multiplier: 1.0, constant: 0.08*self.dim.height),
            NSLayoutConstraint(item: searchBar as Any, attribute: .centerX,
                           relatedBy: .equal,
                           toItem: self.view, attribute: .centerX,
                           multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .centerX,
                              relatedBy: .equal,
                              toItem: searchBar, attribute: .centerX,
                              multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .top,
                              relatedBy: .equal,
                              toItem: searchBar, attribute: .bottom,
                              multiplier: 1.0, constant: 0.02*dim.height)
        ])
        searchResultsView.setConstraintsToView(bottom: self.view, left: searchBar, right: searchBar)
        
        searchBar.setHeightConstraint(0.07*dim.height)
        searchBar.setWidthConstraint(0.9*dim.width)
        
        self.view.layoutIfNeeded()
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
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            self.searchResultsView.isHidden = false
        } else {
            self.searchResultsView.isHidden = true
            self.searchResultsView.isScrolling = false
        }
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

extension MapViewController: SearchBarDelegate {
    func searchbarTextDidChange(_ textField: UITextField) {
        if textField.text != nil {
            searchLocations(textField.text!)
        }
        searchResultsView.state = .loading
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResultsView(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard !searchResultsView.isScrolling else { return }
        showSearchResultsView(false)
        searchBar.setButtonStates(hasInput: textField.text?.count != 0, isSearching: false)
    }
    
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    private func searchLocations(_ keyword: String, completion: (([CLPlacemark], Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = keyword
            request.region = self.mapView.region
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                var placemarks = [CLPlacemark]()
                if let response = response {
                    for item in response.mapItems {
                        placemarks.append(item.placemark)
                    }
                }
                DispatchQueue.main.async {
                    self.searchResultsView.updateTable(newPlacemarks: placemarks, error: error)
                    completion?(placemarks, error)
                }
            }
        }
    }
}



