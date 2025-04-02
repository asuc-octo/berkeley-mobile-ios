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

    open var mainContainer: MainContainerViewController?
    var pinDelegate: SearchResultsViewDelegate?
    
    private var mapView: MKMapView!
    private var mapUserLocationButton: UIView!
    private var mapMarkersDropdownButton: UIView!
    
    private var searchBarViewController: UIViewController!
    private var searchBar: UIView!
    private var searchResultsView: UIView!
    private var searchResultsHostingController: UIHostingController<AnyView>!
    private var searchViewModel: SearchViewModel!
    
    private var compass: MKCompassButton!
    
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    
    private var searchAnnotation: SearchAnnotation?
    
    private var previousMapMarker:MapMarker?
    private var previousPlaceMark: MKAnnotation?
    
    private var filters: [Filter<[MapMarker]>] = []
    private var mapUserLocationButtonTapped = false
    private let mapUserLocationViewModel = MapUserLocationButtonViewModel()
    private let mapMarkersDropdownViewModel = MapMarkersDropdownViewModel()
    private var mapMarkers: [[MapMarker]] = []
    private var markerDetail: UIHostingController<MapMarkerDetailSwiftView>!
    
    var homeViewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutMargins = UIEdgeInsets(top: kLayoutMarginsInset + 50, left: kLayoutMarginsInset, bottom: kLayoutMarginsInset, right: kLayoutMarginsInset)
        
        mapView = MKMapView()
        mapView.delegate = self
        
        setMapBoundsAndZoom()
        
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MapViewController.kAnnotationIdentifier)
        mapView.showsUserLocation = true
        
        createSearchBarComponents()
        addChild(searchBarViewController)
        
        createMarkerDetailView()
        
        fetchFromMapDataSource()
        createMapLocationButton()
        createMapMarkerDropdownButton()
        
        self.view.addSubViews([mapView, mapUserLocationButton, mapMarkersDropdownButton, markerDetail.view, searchResultsView, searchBar])
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
    
    private func dismissMarkerDetail() {
        mapView.selectedAnnotations.forEach { annotation in
            if annotation.isKind(of: MapMarker.self) {
                mapView.deselectAnnotation(annotation, animated: true)
                homeViewModel?.isShowingDrawer = true
            }
        }
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
        searchViewModel = SearchViewModel(chooseMapMarker: { mapMarker in
            self.chooseMapMarker(mapMarker)
        }) { placemark in
            self.choosePlacemark(placemark)
        }
        
        let searchBarView = SearchBarView(onSearchBarTap: { [weak self] isSearching in
            guard let self else {
                return
            }
            self.homeViewModel?.isShowingDrawer = !isSearching
            self.showSearchResultsView(isSearching)
        })
        
        searchBarViewController = UIHostingController(rootView: searchBarView.environmentObject(searchViewModel))
        
        searchBar = searchBarViewController.view
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.isUserInteractionEnabled = true
        searchBar.backgroundColor = .clear
        
        let resultsView = SearchResultsView().environmentObject(searchViewModel)
        searchResultsHostingController = UIHostingController(rootView: AnyView(resultsView))
        searchResultsView = searchResultsHostingController.view
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsView.backgroundColor = .clear
        addChild(searchResultsHostingController)
        searchResultsHostingController.didMove(toParent: self)
        showSearchResultsView(false)
    }
    
    private func createMarkerDetailView() {
        // Create a temporary variable for the view
        let markerDetailView = MapMarkerDetailSwiftView(marker: nil, onClose: { [weak self] in
            self?.dismissMarkerDetail()
        })
        
        // Assign to the class property
        markerDetail = UIHostingController(rootView: markerDetailView)
        markerDetail.view.backgroundColor = .clear
        markerDetail.view.isHidden = true
        markerDetail.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(markerDetail)
        markerDetail.didMove(toParent: self)
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
    
    private func updateCompassPosition() {
        if compass != nil { return }
        mapView.showsCompass = false
        compass = MKCompassButton(mapView: mapView)
        view.insertSubview(compass, belowSubview: searchResultsView)
        // Position the compass to bottom-right of `FilterView`
        compass.translatesAutoresizingMaskIntoConstraints = false
        compass.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        compass.topAnchor.constraint(equalTo: mapUserLocationButton.bottomAnchor, constant: kViewMargin).isActive = true
    }
    
    @objc func homePressed() {
        if !markerDetail.view.isHidden {
            markerDetail.view.isHidden = true
            mapView.selectedAnnotations.forEach { annotation in
                if annotation.isKind(of: MapMarker.self) {
                    mapView.deselectAnnotation(annotation, animated: true)
                }
            }
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
        
        let searchBarTopMargin: CGFloat = 74
        let searchBarHeight = searchBar.intrinsicContentSize.height
        let mapBtnsTopMargin: CGFloat = 141
        let markerDetailBottomMargin: CGFloat = -96
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: searchBarTopMargin),
            searchBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: searchBarHeight),
            
            searchResultsView.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            markerDetail.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: markerDetailBottomMargin),
            markerDetail.view.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            markerDetail.view.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
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
            searchResultsView.isHidden = false
            mainContainer?.hideTop()
        } else {
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


// MARK: - MKMapViewDelegate, Analytics

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
        if let annotation = view.annotation as? MapMarker {
            UIView.animate(withDuration: 0.1) {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
            Analytics.logEvent("point_of_interest_clicked", parameters: ["Place": annotation.title ?? "Unknown"])
            
            let markerDetailView = MapMarkerDetailSwiftView(marker: annotation, onClose: { [weak self] in
                self?.dismissMarkerDetail()
            })
            markerDetail.rootView = markerDetailView
            markerDetail.view.isHidden = false
            
            mainContainer?.hideTop()
            homeViewModel?.isShowingDrawer = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (view.annotation as? MapMarker) != nil {
            UIView.animate(withDuration: 0.1) {
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
            markerDetail.view.isHidden = true
            homeViewModel?.isShowingDrawer = true

            DispatchQueue.main.async {
                if self.mapView.selectedAnnotations.isEmpty {
                    self.mainContainer?.showTop()
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapUserLocationViewModel.isHomingInOnUserLocation = mapUserLocationButtonTapped
    }
}


// MARK: - SearchResultsViewDelegate

extension MapViewController: SearchResultsViewDelegate {

    func choosePlacemark(_ placemark: MapPlacemark) {
        
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
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius)
            mapView.setRegionWithDuration(coordinateRegion, duration: 0.5)
            let item = placemark.item
            if let item {
                let annotation: SearchAnnotation = SearchAnnotation(item: item, location: location.coordinate)
                annotation.title = item.searchName
                searchAnnotation = annotation
                
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
                
                if !markerDetail.view.isHidden {
                    markerDetail.view.isHidden = true
                    mapView.selectedAnnotations.forEach { annotation in
                        if annotation.isKind(of: MapMarker.self) {
                            mapView.deselectAnnotation(annotation, animated: true)
                        }
                    }
                }
                
                
                if let type = type(of: item) as? AnyClass {
                    homeViewModel?.isShowingDrawer = true
                    homeViewModel?.presentDetail(type: type, item: item)
                }
            }
        }
        DispatchQueue.main.async {
            self.showSearchResultsView(false)
        }
    }
    
    
    func chooseMapMarker(_ mapMarker: MapMarker) {
        
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
            let coordinateLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.0, location.1)
            let coordinateRegion = MKCoordinateRegion(center: coordinateLocation,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegionWithDuration(coordinateRegion, duration: 0.5)
            
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

extension MKMapView {
    func setRegionWithDuration(_ zoomRegion: MKCoordinateRegion, duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 10, options: .curveEaseIn) {
            self.setRegion(zoomRegion, animated: true)
        }
    }
}
