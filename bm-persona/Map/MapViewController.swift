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
    private var detailViewController = SearchDetailViewController()
    private var initialDetailCenter = CGPoint()
    private var searchDetailStatePositions: [SearchDetailState: CGFloat] = [:]
    private var searchAnnotation: SearchAnnotation?
    
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
        searchResultsView.delegate = self
        showSearchResultsView(false)
        
        markerDetail = MapMarkerDetailView()
        markerDetail.delegate = self
        markerDetail.marker = nil
        
        filterView = FilterView(frame: .zero)
        filterView.allowsMultipleSelection = false
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
        add(child: detailViewController)
    }
    
    private func setupSubviews() {
        maskView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        
        searchResultsView.setConstraintsToView(bottom: maskView, left: searchBar, right: searchBar)
        self.view.addConstraint(NSLayoutConstraint(item: searchResultsView, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .bottom, multiplier: 1, constant: 0))
        
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
            self.detailViewController.view.isHidden = true
        } else {
            self.maskView.isHidden = true
            self.searchResultsView.isHidden = true
            self.searchResultsView.isScrolling = false
            self.detailViewController.view.isHidden = false
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
                self.removeAnnotations(type: MapMarker.self)
                self.mapView.addAnnotations(Array(filtered.joined()))
            }
        })
    }
    
    func removeAnnotations<T>(type: T.Type) {
        var remove: [MKAnnotation] = []
        for annotation in self.mapView.annotations {
            if annotation.isKind(of: type as! AnyClass) {
                remove.append(annotation)
            }
        }
        self.mapView.removeAnnotations(remove)
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
        } else if let searchAnnotation = annotation as? SearchAnnotation,
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            annotationView.annotation = searchAnnotation
            annotationView.glyphImage = searchAnnotation.icon()
            annotationView.contentMode = .scaleToFill
            annotationView.markerTintColor = searchAnnotation.color()
            annotationView.glyphTintColor = .white
            annotationView.setSelected(true, animated: true)
            return annotationView
        }
        return MKAnnotationView()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? SearchAnnotation {
            if annotation.selectedFromTap {
                moveSearchDetailView(to: .middle, duration: 0.2)
            }
        } else {
            markerDetail.marker = view.annotation as? MapMarker
            drawerContainer?.moveDrawer(to: .hidden, duration: 0.2)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotation = view.annotation as? SearchAnnotation {
            if annotation.selectedFromTap {
                removeAnnotations(type: SearchAnnotation.self)
                detailViewController.view = UIView()
                detailViewController.setupBarView()
                searchAnnotation = nil
                drawerContainer?.moveDrawer(to: .collapsed, duration: 0.2)
            }
        } else {
            markerDetail.marker = nil
            drawerContainer?.moveDrawer(to: .collapsed, duration: 0.2)
        }
    }
    
}

// MARK: MapMarkerDetailViewDelegate

extension MapViewController: MapMarkerDetailViewDelegate {
    
    func didCloseMarkerDetailView(_ sender: MapMarkerDetailView) {
        mapView.selectedAnnotations.forEach { annotation in
            if annotation.isKind(of: MapMarker.self) {
                mapView.deselectAnnotation(annotation, animated: true)
            }
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
                let place = MapPlacemark(loc: cl, name: item.searchName, locName: item.locationName, item: item)
                
                placemarks.append(place)
            }
            DispatchQueue.main.async {
                self.searchResultsView.updateTable(newPlacemarks: placemarks, error: nil)
                completion?(placemarks, nil)
            }
            
        }
    }
}

extension MapViewController: SearchResultsViewDelegate, SearchDetailViewDelegate {
    
    func choosePlacemark(_ placemark: MapPlacemark) {
        let location = placemark.location
        showSearchResultsView(false)
        searchBar.textFieldDidEndEditing(searchBar.textField)
        searchBar.textField.text = ""
        removeAnnotations(type: SearchAnnotation.self)
        if location != nil {
            let regionRadius: CLLocationDistance = 250
            let coordinateRegion = MKCoordinateRegion(center: location!.coordinate,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            let item = placemark.item
            if item != nil {
                let annotation = SearchAnnotation(item: item!, location: location!.coordinate)
                annotation.title = item!.searchName
                searchAnnotation = annotation
                mapView.addAnnotation(annotation)
                drawerContainer?.moveDrawer(to: .hidden, duration: 0.2)
                
                //TODO: set up actual detail view
                let detailView = UIView()
                detailView.backgroundColor = .red
                detailView.layer.cornerRadius = 40
                detailView.clipsToBounds = true
                detailViewController.view = detailView
                
                let superView = detailViewController.view.superview!
                detailViewController.delegate = self
                detailViewController.view.translatesAutoresizingMaskIntoConstraints = false
                detailViewController.view.heightAnchor.constraint(equalTo: superView.heightAnchor).isActive = true
                detailViewController.view.widthAnchor.constraint(equalTo: superView.widthAnchor).isActive = true
                detailViewController.view.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
                detailViewController.view.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: self.view.frame.maxY * 0.7).isActive = true
                detailViewController.view.layoutIfNeeded()
                detailViewController.setupBarView()
                
                searchDetailStatePositions[.hidden] = superView.frame.maxY + superView.frame.maxY / 2
                searchDetailStatePositions[.middle] = superView.frame.midY + superView.frame.maxY * 0.7
                searchDetailStatePositions[.full] = superView.safeAreaInsets.top + (superView.frame.maxY / 2)
                initialDetailCenter = detailViewController.view.center
                detailViewController.setupGestures()
                moveSearchDetailView(to: .middle, duration: 0)
                annotation.selectedFromTap = false
                mapView.selectAnnotation(annotation, animated: true)
                annotation.selectedFromTap = true
            }
        }
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            self.initialDetailCenter = detailViewController.view.center
        }
        
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view).y
        var newCenter = CGPoint(x: self.initialDetailCenter.x, y: self.initialDetailCenter.y + translation.y)
        
        if newCenter.y < self.view.center.y {
            newCenter = self.view.center
        }
        
        if gesture.state == .ended {
            let searchDetailState = computeSearchDetailPosition(from: newCenter.y, with: velocity)
            let pixelDiff = abs(newCenter.y - searchDetailStatePositions[searchDetailState]!)
            var animationTime = pixelDiff / abs(velocity)
            
            if pixelDiff / animationTime < 300 {
                animationTime = pixelDiff / 300
            } else if pixelDiff / animationTime > 700 {
                animationTime = pixelDiff / 700
            }
            
            moveSearchDetailView(to: searchDetailState, duration: Double(animationTime))
            if searchDetailState == .hidden {
                if searchAnnotation != nil {
                    searchAnnotation!.selectedFromTap = false
                    mapView.deselectAnnotation(searchAnnotation, animated: true)
                    searchAnnotation!.selectedFromTap = true
                }
            }
            
        } else {
            self.detailViewController.view.center = newCenter
        }
        
        
    }
    
    private func computeSearchDetailPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> SearchDetailState {
        guard let hiddenPos = searchDetailStatePositions[SearchDetailState.hidden], let middlePos = searchDetailStatePositions[SearchDetailState.middle], let fullPos = searchDetailStatePositions[SearchDetailState.full] else { return .middle }
        
        let betweenBottom = (hiddenPos + middlePos) / 2
        let betweenTop = (middlePos + fullPos) / 2
        
        if yPosition > betweenBottom {
            if yVelocity < -800 {
                return .middle
            } else {
                return .hidden
            }
        } else if yPosition > betweenTop {
            if yVelocity > 800 {
                return .hidden
            } else if yVelocity < -800 {
                return .full
            } else {
                return .middle
            }
        } else if yVelocity > 800 {
            return .middle
        } else {
            return .full
        }
    }
    
    func moveSearchDetailView(to state: SearchDetailState, duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.detailViewController.view.center = CGPoint(x: self.initialDetailCenter.x, y: self.searchDetailStatePositions[state]!)
        }, completion: { success in
            if success {
                self.detailViewController.state = state
            }
        })
    }
}

