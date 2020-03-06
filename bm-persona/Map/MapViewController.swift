//
//  ViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

// MARK: - MapViewController

class MapViewController: UIViewController {
    
    static let kAnnotationIdentifier = "MapMarkerAnnotation"
    
    open var drawerContainer: DrawerContainer?
    
    private var mapView: MKMapView!
    private var maskView: UIView!
    private var searchBar: SearchBarView!
    private var searchResultsView: SearchResultsView!
    private var locationManager = CLLocationManager()
    
    private var filterView: FilterView!
    private var filters: [Filter<[MapMarker]>] = MapMarkerType.allCases.map { type in
        Filter(label: type.rawValue) { $0.first?.type == type }
    }
    private var mapMarkers: [[MapMarker]] = []
    private var markerDetail: MapMarkerDetailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 21, left: 21, bottom: 21, right: 21)
        
        mapView = MKMapView()
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MapViewController.kAnnotationIdentifier)
        
        maskView = UIView()
        maskView.backgroundColor = Color.searchBarBackground
        
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
        
        markerDetail = MapMarkerDetailView()
        markerDetail.delegate = self
        markerDetail.marker = nil
        
        filterView = FilterView(frame: .zero)
        filterView.filterDelegate = self
        filterView.labels = filters.map { $0.label }
        
        DataManager.shared.fetch(source: MapDataSource.self) { markers in
            self.mapMarkers = markers as? [[MapMarker]] ?? []
        }
        
        requestLocation()
        
        self.view.addSubViews([mapView, filterView, markerDetail, maskView, searchResultsView, searchBar])
        setupSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (mapView.isZoomEnabled, mapView.showsUserLocation) = (true, true)
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func setupSubviews() {
        maskView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        
        searchResultsView.setConstraintsToView(top: maskView, bottom: maskView, left: searchBar, right: searchBar)
        
        searchBar.setHeightConstraint(50)
        searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        markerDetail.translatesAutoresizingMaskIntoConstraints = false
        markerDetail.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        markerDetail.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        markerDetail.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.heightAnchor.constraint(equalToConstant: FilterViewCell.kCellSize.height).isActive = true
        filterView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24).isActive = true
        filterView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        filterView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        filterView.contentInset = UIEdgeInsets(top: 0, left: view.layoutMargins.left,
                                               bottom: 0, right: view.layoutMargins.right)
    }
    
    private func requestLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            self.maskView.isHidden = false
            self.searchResultsView.isHidden = false
        } else {
            self.maskView.isHidden = true
            self.searchResultsView.isHidden = true
            self.searchResultsView.isScrolling = false
        }
    }
    
    // MARK: - Map Markers
    
    var workItem: DispatchWorkItem?
    private func updateMapMarkers() {
        workItem?.cancel()
        let selectedIndices = filterView.indexPathsForSelectedItems?.map { $0.row }
        workItem = Filter.satisfiesAny(filters: filters, on: mapMarkers, indices: selectedIndices, completion: {
            filtered in
            DispatchQueue.main.async {
                // TODO: Speed this up?
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(Array(filtered.joined()))
            }
        })
    }

}

// MARK: FilterViewDelegate

extension MapViewController: FilterViewDelegate {

    func filterView(_ filterView: FilterView, didSelect index: Int) {
        updateMapMarkers()
    }
    
    func filterView(_ filterView: FilterView, didDeselect index: Int) {
        updateMapMarkers()
    }
    
}

// MARK: MKMapViewDelegate {

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let marker = annotation as? MapMarker,
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewController.kAnnotationIdentifier) {
            annotationView.annotation = marker
            annotationView.image = marker.type.icon()
            return annotationView
        }
        return MKAnnotationView()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        markerDetail.marker = view.annotation as? MapMarker
        drawerContainer?.moveDrawer(to: .hidden, duration: 0.2)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        markerDetail.marker = nil
        drawerContainer?.moveDrawer(to: .collapsed, duration: 0.2)
    }
}

// MARK: MapMarkerDetailViewDelegate

extension MapViewController: MapMarkerDetailViewDelegate {
    
    func didCloseMarkerDetailView(_ sender: MapMarkerDetailView) {
        mapView.selectedAnnotations.forEach { annotation in
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
}


// MARK: - CLLocationManagerDelegate

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

// MARK: - SearchBarDelegate

extension MapViewController: SearchBarDelegate {
    func searchbarTextDidChange(_ textField: UITextField) {
        searchResultsView.state = .loading

        if textField.text != nil {
            searchLocations(textField.text!)
        }
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
    
    private func searchLocations(_ keyword: String, completion: (([MapPlacemark], Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            let data = DataManager.shared.searchable
            let filtered = data.filter { ($0.searchName.contains(keyword) && $0.location.0 != 0 && $0.location.1 != 0) }
            var placemarks = [MapPlacemark]()

            for item in filtered {
                let cl = CLLocation(latitude: CLLocationDegrees(item.location.0), longitude: CLLocationDegrees(item.location.1))
                let place = MapPlacemark(loc: cl, name: item.searchName, locName: item.locationName)
                
                placemarks.append(place)
            }
            DispatchQueue.main.async {
                self.searchResultsView.updateTable(newPlacemarks: placemarks, error: nil)
                completion?(placemarks, nil)
            }
            
        }
    }
}



