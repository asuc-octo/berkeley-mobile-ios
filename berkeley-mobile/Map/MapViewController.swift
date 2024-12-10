//
//  ViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import SwiftUI
import MapKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

// MARK: - MapViewController

class MapViewController: UIViewController, SearchDrawerViewDelegate {

    static let kAnnotationIdentifier = "MapMarkerAnnotation"
    
    private enum UserLocationButtonStyle {
        case outline
        case filled
    }

    // this allows the map to move the main drawer
    open var mainContainer: MainContainerViewController?
    var pinDelegate: SearchResultsViewDelegate?
    
    private var mapView: MKMapView!
    private var maskView: UIView!
    private var searchBar: SearchBarView!
    private var searchResultsView: SearchResultsView!
    private var mapMarkersDropdownButton: UIView!
    private var userLocationButton: UIButton!
    private var compass: MKCompassButton!
    private var locationButtonTapped: Bool!
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    
    private var searchAnnotation: SearchAnnotation?
    
    //variables for search markers
    private var previousMapMarker:MapMarker?
    private var previousPlaceMark: MKAnnotation?
    
    private var filterView: FilterView!
    private var filters: [Filter<[MapMarker]>] = [] {
        didSet {
            filterView.labels = filters.map { $0.label }
        }
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
        maskView.backgroundColor = BMColor.searchBarBackground
        mapView.showsUserLocation = true
        
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
        filterView.animating = true
        filterView.allowsMultipleSelection = false
        filterView.filterDelegates.append(self)
        
        createMapMarkerDropdownButton()
        
        DataManager.shared.fetch(source: MapDataSource.self) { markers in
            guard let markers = markers.first as? [String: [MapMarker]] else { return }
            self.mapMarkers = Array(markers.values)
            var types = Array(markers.keys)
            
            types.sort {
                guard let rhs = MapMarkerType(rawValue: $1) else { return true }
                guard let lhs = MapMarkerType(rawValue: $0) else { return false }
                return lhs < rhs
            }
            self.filters = types.map { type in
                Filter(label: type) { $0.first?.type.rawValue == type }
            }
        }
        
        self.view.addSubViews([mapView, filterView, mapMarkersDropdownButton, markerDetail, maskView, searchResultsView, searchBar])
        setupSubviews()
        userLocationButton = UIButton(type: .custom)
        view.addSubview(userLocationButton)

        // Listen for home button press
        NotificationCenter.default.addObserver(self,
            selector: #selector(homePressed),
            name: Notification.Name(TabBarController.homePressedMessage),
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.isZoomEnabled = true
        centerMapOnLocation(CLLocation(latitude: CLLocationDegrees(exactly: 37.871684)!, longitude: CLLocationDegrees(-122.259934)), mapView: mapView, animated: false)
        updateCompassPosition()
        updateUserLocationButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let isUserLocationButtonTapped = locationButtonTapped != nil && locationButtonTapped!
        updateUserLocationButtonImage(withStyle: isUserLocationButtonTapped ? .filled : .outline)
    }
    
    private func createMapMarkerDropdownButton() {
        let mapMarkersDropdownButtonView = MapMarkersDropdownButton { [weak self] selectedType in
            guard let self = self else { return }
            if let selectedIndex = self.filterView.labels.firstIndex(of: selectedType.rawValue) {
                showMapMarkersFromFilterView(for: self.filters, on: self.mapMarkers, with: [selectedIndex])
                self.filterView.selectItem(index: selectedIndex)
            }
        }
    
        mapMarkersDropdownButton = UIHostingController(rootView: mapMarkersDropdownButtonView).view
        mapMarkersDropdownButton.translatesAutoresizingMaskIntoConstraints = false
        mapMarkersDropdownButton.isUserInteractionEnabled = true
        mapMarkersDropdownButton.backgroundColor = UIColor.clear
    }
    
    private func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView, animated: Bool) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: animated)
    }

    /// Repoisitions the map's compass so that it is not obscured by the search bar.
    private func updateCompassPosition() {
        if compass != nil { return }
        mapView.showsCompass = false
        compass = MKCompassButton(mapView: mapView)
        view.insertSubview(compass, belowSubview: maskView)
        // Position the compass to bottom-right of `FilterView`
        compass.translatesAutoresizingMaskIntoConstraints = false
        compass.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        compass.topAnchor.constraint(equalTo: userLocationButton.bottomAnchor, constant: kViewMargin).isActive = true
    }
    
    //sets up user location button properties
    private func updateUserLocationButton() {
        userLocationButton.clipsToBounds = true
        userLocationButton.layer.masksToBounds = false
        userLocationButton.backgroundColor = BMColor.modalBackground
        userLocationButton.layer.cornerRadius = mapView.frame.width * 0.12 * 0.5
        userLocationButton.layer.shadowRadius = 5
        userLocationButton.layer.shadowOpacity = 0.2
        userLocationButton.layer.shadowColor = UIColor.black.cgColor
        userLocationButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        userLocationButton.addTarget(self, action: #selector(jumpToUserLocation), for: .touchUpInside)
        let _buttonWidth = mapView.frame.width * 0.12
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        userLocationButton.widthAnchor.constraint(equalToConstant: _buttonWidth).isActive = true
        userLocationButton.heightAnchor.constraint(equalToConstant: _buttonWidth).isActive = true
        userLocationButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        userLocationButton.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: kViewMargin).isActive = true
        updateUserLocationButtonImage(withStyle: .outline)
    }

    @objc func homePressed() {
        // Dismiss any map markers if opened
        if markerDetail.marker != nil {
            mapView.deselectAnnotation(markerDetail.marker, animated: true)
        }
    }
    
    @objc func jumpToUserLocation() {
        if LocationManager.shared.userLocation != nil {
            centerMapOnLocation(LocationManager.shared.userLocation!, mapView: mapView, animated: true)
            updateUserLocationButtonImage(withStyle: .filled)
            locationButtonTapped = true
        }
    }
    
    private func updateUserLocationButtonImage(withStyle style: UserLocationButtonStyle) {
        switch style {
        case .outline:
            userLocationButton.setImage(UIImage(named: "navigation-outline")!.colored(BMColor.blackText), for: .normal)
        case .filled:
            userLocationButton.setImage(UIImage(named: "navigation-filled")!.colored(BMColor.blackText), for: .normal)
        }
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
        filterView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: kViewMargin).isActive = true
        filterView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        filterView.contentInset = UIEdgeInsets(top: 0, left: view.layoutMargins.left,
                                               bottom: 0, right: view.layoutMargins.right)
        
        NSLayoutConstraint.activate([
            mapMarkersDropdownButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mapMarkersDropdownButton.widthAnchor.constraint(equalToConstant: 40),
            mapMarkersDropdownButton.heightAnchor.constraint(equalToConstant: 40),
            mapMarkersDropdownButton.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: kViewMargin + 5)
        ])
    }
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            self.maskView.isHidden = false
            self.searchResultsView.isHidden = false
            mainContainer?.hideTop()
            self.userLocationButton.isHidden = true
        } else {
            self.maskView.isHidden = true
            self.searchResultsView.isHidden = true
            self.searchResultsView.isScrolling = false
            mainContainer?.showTop()
            self.userLocationButton?.isHidden = false
        }
    }
    
    // MARK: - Map Markers
    
    private func showMapMarkersFromFilterView(for filters: [Filter<[MapMarker]>], on mapMarkers: [[MapMarker]], with indices: [Int]?) {
        _ = Filter.satisfiesAny(filters: filters, on: mapMarkers, indices: indices, completion: {
            filtered in
            DispatchQueue.main.async {
                // TODO: Speed this up?
                // remove only map markers, not search annotations
                self.removeAnnotations(type: MapMarker.self)
                self.mapView.addAnnotations(Array(filtered.joined()))
            }
        })
    }
    
    var workItem: DispatchWorkItem?
    private func updateMapMarkers() {
        self.previousMapMarker = nil
        workItem?.cancel()
        let selectedIndices = filterView.indexPathsForSelectedItems?.map { $0.row }
        workItem = Filter.satisfiesAny(filters: filters, on: mapMarkers, indices: selectedIndices, completion: {
            [weak self] filtered in
            guard let self = self else { return }
            self.showMapMarkersFromFilterView(for: self.filters, on: self.mapMarkers, with: selectedIndices)
        })
    }
    
    // remove all annotations on the map of one type
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

// MARK: FilterViewDelegate, Analytics

extension MapViewController: FilterViewDelegate {

    func filterView(_ filterView: FilterView, didSelect index: Int) {
        if let category = filters[safe: index]?.label {
            // Log the display name of the marker category that is selected.
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": category])
        }
        updateMapMarkers()
    }
    
    func filterView(_ filterView: FilterView, didDeselect index: Int) {
        updateMapMarkers()
    }
}

// MARK: MKMapViewDelegate, Analytics {

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
           return nil
        } else if let marker = annotation as? MapMarker,
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewController.kAnnotationIdentifier) {
            annotationView.annotation = marker
            if case .known(let type) = marker.type {
                annotationView.image = type.icon()
            } else {
                annotationView.image = MapMarkerType.none.icon()
            }
            return annotationView
        } else if let searchAnnotation = annotation as? SearchAnnotation,
            // create new pin on map for searched item
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            annotationView.displayPriority = .required
            annotationView.annotation = searchAnnotation
            annotationView.glyphImage = searchAnnotation.icon()
            annotationView.contentMode = .scaleToFill
            annotationView.markerTintColor = searchAnnotation.color()
            annotationView.glyphTintColor = .white
            return annotationView
        }
        return MKAnnotationView()
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // if map marker is selected, hide the top drawer to show the marker detail
        if let annotation = view.annotation as? MapMarker {
            UIView.animate(withDuration: 0.1, animations: {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            // Log the display name of the marker that is selected, `Unknown` if no title exists.
            Analytics.logEvent("point_of_interest_clicked", parameters: ["Place": annotation.title ?? "Unknown"])
            markerDetail.marker = annotation
            mainContainer?.hideTop()
        }
    }
 
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (view.annotation as? MapMarker) != nil {
            UIView.animate(withDuration: 0.1, animations: {
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            markerDetail.marker = nil
            // if a marker is deselected wait to see if another marker was selected
            DispatchQueue.main.async {
                // if no other marker was selected, show the top drawer
                if self.markerDetail.marker == nil {
                    self.mainContainer?.showTop()
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard userLocationButton != nil else {return}
        guard locationButtonTapped != nil else {return}
        if !locationButtonTapped {
            userLocationButton.setImage(UIImage(named: "navigation-filled")!.colored(BMColor.blackText), for: .normal)
        } else {
            userLocationButton.setImage(UIImage(named: "navigation-outline")!.colored(BMColor.blackText), for: .normal)
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
            let filtered = data.filter { ($0.searchName.lowercased().contains(keyword.lowercased()) && $0.location.0 != 0 && $0.location.1 != 0) }
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

extension MapViewController: SearchResultsViewDelegate {

    func choosePlacemark(_ placemark: MapPlacemark) {
        // remove last search pin
        
        if let previousPlaceMark = self.previousPlaceMark {
            self.mapView.removeAnnotation(previousPlaceMark)
            self.previousPlaceMark = nil
        }
        if let previousMapMarker = self.previousMapMarker {
            self.mapView.removeAnnotation(previousMapMarker)
            self.previousMapMarker = nil
        }
        
        if let location = placemark.location, location.coordinate.latitude != Double.nan && location.coordinate.longitude != Double.nan {
            let regionRadius: CLLocationDistance = 250
            // center map on searched location
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            let item = placemark.item
            if let item = item {
                let annotation:SearchAnnotation = SearchAnnotation(item: item, location: location.coordinate)
                annotation.title = item.searchName
                searchAnnotation = annotation
                // add and select marker for search item, remove resource view if any
                
                if self.drawerViewController != nil {
                    self.mainContainer?.dismissTop()
                }
                
                if !mapView.annotations.contains(where: { annot in
                    return annot.isEqual(annotation)
                }) {
                    mapView.addAnnotation(annotation)
                    self.previousPlaceMark = annotation
                }
                mapView.selectAnnotation(annotation, animated: true)
                if markerDetail.marker != nil {
                    mapView.deselectAnnotation(markerDetail.marker, animated: true)
                }
                // if the new search item has a detail view: remove the old detail view, show the new one
                // otherwise: still dismiss any past detail views and show the drawer underneath
                
                if let type = type(of: item) as? AnyClass {
                    presentDetail(type: type, item: item, containingVC: mainContainer!, position: .middle)
                }
            }
        }
        DispatchQueue.main.async {
            // clear text field
            self.showSearchResultsView(false)
            self.searchBar.textField.text = ""
            self.searchBar.textFieldDidEndEditing(self.searchBar.textField)
        }
    }
    
    // drop new pin and show detail view on search
    func chooseMapMarker(_ mapMarker: MapMarker) {
        // remove last search pin
        if let previousPlaceMark = self.previousPlaceMark {
            self.mapView.removeAnnotation(previousPlaceMark)
            self.previousPlaceMark = nil
        }
        if let previousMapMarker = self.previousMapMarker {
            self.mapView.removeAnnotation(previousMapMarker)
            self.previousMapMarker = nil
        }
        
        let location = mapMarker.location
        if location.0 != Double.nan && location.1 != Double.nan {
            let regionRadius: CLLocationDistance = 250
            // center map on searched location
            let coordinateLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.0, location.1)
            let coordinateRegion = MKCoordinateRegion(center: coordinateLocation,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            if !mapView.annotations.contains(where: { annotation in
                return annotation as? MapMarker == mapMarker
            }) {
                mapView.addAnnotation(mapMarker)
                self.previousMapMarker = mapMarker
            }
            mapView.selectAnnotation(mapMarker, animated: true)
        }
        DispatchQueue.main.async {
            // clear text field
            self.searchBar.textField.text = ""
            self.searchBar.textFieldDidEndEditing(self.searchBar.textField)
            self.mainContainer?.hideTop()
        }
    }

}


extension MapViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let state = handlePan(gesture: gesture)
        // get rid of the top detail drawer and remove associated annotation if user sends the drawer to the bottom of the screen
        if state == .hidden {
            handleDrawerDismissal()
            mainContainer?.dismissTop()
        }
    }
    
    func handleDrawerDismissal() {
        removeAnnotations(type: SearchAnnotation.self)
        searchAnnotation = nil
    }
}
