//
//  ViewController.swift
//  bm-persona
//
//  Created by RJ Pimentel on 10/23/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Firebase
import MapKit
import SwiftUI
import UIKit

// MARK: - HomeMapView

struct HomeMapView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MapViewController
    
    private let mapViewController: MapViewController
    
    init(mapViewController: MapViewController) {
        self.mapViewController = mapViewController
    }
    
    func makeUIViewController(context: Context) -> MapViewController {
        mapViewController
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {}
}


// MARK: - MapViewController

fileprivate let kViewMargin: CGFloat = 16
fileprivate let kLayoutMarginsInset: CGFloat = 21

class MapViewController: UIViewController, SearchDrawerViewDelegate {

    static let kAnnotationIdentifier = "MapMarkerAnnotation"

    // this allows the map to move the main drawer
    open var mainContainer: MainContainerViewController?
    var pinDelegate: SearchResultsViewDelegate?
    
    private var mapView: MKMapView!
    private var maskView: UIView!
    private var searchBarViewController: UIViewController!
    private var searchBar: UIView!
    private var searchResultsView: UIView!
    private var mapUserLocationButton: UIView!
    private var mapMarkersDropdownButton: UIView!
    private var compass: MKCompassButton!
    
    private var searchViewModel: SearchViewModel!
    
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    
    private var searchAnnotation: SearchAnnotation?
    
    // Variables for search markers
    private var previousMapMarker:MapMarker?
    private var previousPlaceMark: MKAnnotation?
    
    private var filters: [Filter<[MapMarker]>] = []
    private var mapUserLocationButtonTapped = false
    private let mapUserLocationViewModel = MapUserLocationButtonViewModel()
    private let mapMarkersDropdownViewModel = MapMarkersDropdownViewModel()
    private var mapMarkers: [[MapMarker]] = []
    private var markerDetail: MapMarkerDetailView!
    
    var homeViewModel: HomeViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: kLayoutMarginsInset + 50, left: kLayoutMarginsInset, bottom: kLayoutMarginsInset, right: kLayoutMarginsInset)
        
        mapView = MKMapView()
        mapView.delegate = self
        
        setMapBoundsAndZoom()
        
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MapViewController.kAnnotationIdentifier)
        mapView.showsUserLocation = true
        
        maskView = UIHostingController(rootView: MaskView()).view
        maskView.translatesAutoresizingMaskIntoConstraints = false
        maskView.backgroundColor = UIColor.clear

        createSearchBarComponents() // Initializes searchBarViewController
        addChild(searchBarViewController) // To give access to the focus environment
        
        markerDetail = MapMarkerDetailView()
        markerDetail.translatesAutoresizingMaskIntoConstraints = false
        markerDetail.delegate = self
        markerDetail.marker = nil
        
        fetchFromMapDataSource()
        createMapLocationButton()
        createMapMarkerDropdownButton()
        
        self.view.addSubViews([mapView, mapUserLocationButton, mapMarkersDropdownButton, markerDetail, maskView, searchResultsView, searchBar])
        setupSubviews()
        
        centerMapAtBerkeley()
        
        searchBarViewController.didMove(toParent: self)
    }
    
    private func setMapBoundsAndZoom() {
        mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: BMConstants.mapBoundsRegion)
        let maximumZoom = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: BMConstants.mapMaxZoomDistance)
        mapView.cameraZoomRange = maximumZoom
    }
    
    private func centerMapAtBerkeley() {
        mapView.isZoomEnabled = true
        centerMapOnLocation(BMConstants.berkeleyLocation, mapView: mapView, animated: false)
        updateCompassPosition()
    }
    
    private func fetchFromMapDataSource() {
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
            self.mapMarkersDropdownViewModel.sortMapMarkerTypes(basedOn: self.filters)
            
            // Select the first map marker option
            self.showMapMarkersFromFilterView(for: self.filters, on: self.mapMarkers, with: [0])
        }
    }

    private func createSearchBarComponents() {
        // SearchViewModel
        searchViewModel = SearchViewModel(chooseMapMarker: { mapMarker in
            self.chooseMapMarker(mapMarker)
        }) { placemark in
            self.choosePlacemark(placemark)
        }
        
        // SearchBarView
        let searchBarView = SearchBarView(onSearchBarTap: { [weak self] isSearching in
            guard let self = self else { return }
            self.homeViewModel?.isShowingDrawer = !isSearching
            self.showSearchResultsView(isSearching)
        })
        
        searchBarViewController = UIHostingController(rootView: searchBarView.environmentObject(searchViewModel))
        
        searchBar = searchBarViewController.view
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.isUserInteractionEnabled = true
        searchBar.backgroundColor = UIColor.clear
        
        // SearchResultsView
        searchResultsView = UIHostingController(rootView: SearchResultsView().environmentObject(searchViewModel)).view
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsView.backgroundColor = UIColor.clear
        showSearchResultsView(false)
    }
    
    private func createMapLocationButton() {
        let mapUserLocationButtonView = MapUserLocationButton { [weak self] in
            self?.homeViewModel?.drawerViewState = .small
            self?.jumpToUserLocation()
        }
        
        mapUserLocationButton = UIHostingController(rootView: mapUserLocationButtonView.environmentObject(mapUserLocationViewModel)).view
        mapUserLocationButton.translatesAutoresizingMaskIntoConstraints = false
        mapUserLocationButton.isUserInteractionEnabled = true
        mapUserLocationButton.backgroundColor = UIColor.clear
    }
    
    private func createMapMarkerDropdownButton() {
        let mapMarkersDropdownButtonView = MapMarkersDropdownButton { [weak self] in
            guard let self = self else { return }
            showMapMarkersFromFilterView(for: self.filters, on: self.mapMarkers, with: [mapMarkersDropdownViewModel.selectedFilterIndex])
        }
    
        mapMarkersDropdownButton = UIHostingController(rootView: mapMarkersDropdownButtonView.environmentObject(mapMarkersDropdownViewModel)).view
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

    // Repoisitions the map's compass so that it is not obscured by the search bar.
    private func updateCompassPosition() {
        if compass != nil { return }
        mapView.showsCompass = false
        compass = MKCompassButton(mapView: mapView)
        view.insertSubview(compass, belowSubview: maskView)
        // Position the compass to bottom-right of `FilterView`
        compass.translatesAutoresizingMaskIntoConstraints = false
        compass.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        compass.topAnchor.constraint(equalTo: mapUserLocationButton.bottomAnchor, constant: kViewMargin).isActive = true
    }
    
    @objc func homePressed() {
        // Dismiss any map markers if opened
        if markerDetail.marker != nil {
            mapView.deselectAnnotation(markerDetail.marker, animated: true)
        }
    }
    
    func jumpToUserLocation() {
        guard let userLocation = LocationManager.shared.userLocation else {
            return
        }
        
        mapUserLocationButtonTapped = true
        centerMapOnLocation(userLocation, mapView: mapView, animated: true)
        mapUserLocationButtonTapped = false
    }
    
    private func setupSubviews() {
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        
        let searchBarTopMargin: CGFloat = 74 // 74.0 from view.topAnchor
        let searchBarHeight = searchBar.intrinsicContentSize.height // Prints 54.0
        let mapBtnsTopMargin: CGFloat = 141
        let markerDetailBottomMargin: CGFloat = -96
        
        NSLayoutConstraint.activate([
            maskView.topAnchor.constraint(equalTo: view.topAnchor),
            maskView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            maskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: searchBarTopMargin),
            searchBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: searchBarHeight),
            
            searchResultsView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            searchResultsView.bottomAnchor.constraint(equalTo: maskView.bottomAnchor),
            searchResultsView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            searchResultsView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            
            markerDetail.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: markerDetailBottomMargin),
            markerDetail.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            markerDetail.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            mapUserLocationButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mapUserLocationButton.topAnchor.constraint(equalTo: view.topAnchor, constant: mapBtnsTopMargin),
            mapUserLocationButton.widthAnchor.constraint(equalToConstant: BMControlButtonStyle.widthAndHeight),
            mapUserLocationButton.heightAnchor.constraint(equalToConstant: BMControlButtonStyle.widthAndHeight),
            
            mapMarkersDropdownButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mapMarkersDropdownButton.widthAnchor.constraint(equalToConstant: BMControlButtonStyle.widthAndHeight),
            mapMarkersDropdownButton.heightAnchor.constraint(equalToConstant: BMControlButtonStyle.widthAndHeight),
            mapMarkersDropdownButton.topAnchor.constraint(equalTo: view.topAnchor, constant: mapBtnsTopMargin)
        ])
    }
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            maskView.isHidden = false
            searchResultsView.isHidden = false
            mainContainer?.hideTop()
        } else {
            maskView.isHidden = true
            searchResultsView.isHidden = true
            DispatchQueue.main.async {
                self.homeViewModel?.drawerViewState = .small
            }
            mainContainer?.showTop()
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
        workItem = Filter.satisfiesAny(filters: filters, on: mapMarkers, indices: [mapMarkersDropdownViewModel.selectedFilterIndex], completion: {
            [weak self] filtered in
            guard let self = self else { return }
            self.showMapMarkersFromFilterView(for: self.filters, on: self.mapMarkers, with: [mapMarkersDropdownViewModel.selectedFilterIndex])
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

// MARK: - FilterViewDelegate, Analytics

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

// MARK: - MKMapViewDelegate, Analytics {

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
            homeViewModel?.isShowingDrawer = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (view.annotation as? MapMarker) != nil {
            UIView.animate(withDuration: 0.1, animations: {
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            
            markerDetail.marker = nil
            homeViewModel?.isShowingDrawer = true

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
        mapUserLocationViewModel.isHomingInOnUserLocation = mapUserLocationButtonTapped
    }
    
}

// MARK: - MapMarkerDetailViewDelegate

extension MapViewController: MapMarkerDetailViewDelegate {
    
    func didCloseMarkerDetailView(_ sender: MapMarkerDetailView) {
        mapView.selectedAnnotations.forEach { annotation in
            if annotation.isKind(of: MapMarker.self) {
                mapView.deselectAnnotation(annotation, animated: true)
                homeViewModel?.isShowingDrawer = true
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
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius)
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
                    homeViewModel?.isShowingDrawer = true
                    homeViewModel?.presentDetail(type: type, item: item)
                }
            }
        }
        DispatchQueue.main.async {
            // clear text field
            self.showSearchResultsView(false)
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
            
            homeViewModel?.isShowingDrawer = false
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
