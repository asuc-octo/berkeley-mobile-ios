//
//  CampusMapViewController.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 1/1/19.
//  Copyright © 2019 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class CampusMapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var campusMapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var shortcutCollectionView: UICollectionView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var detailTableView: UITableView!
    var detailViewController: DetailTableViewController!
    
    var shortcutStackView: UIStackView!
    var shortcutView: UIView!
    let campusMapModel = CampusMapModel()
    var mapMarkers: [String: [MKPinAnnotationView]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get rid of searchBar background
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
        campusMapView.delegate = self
        registerMapAnnotationViews()
        
        centerMapOnLocation(location: CLLocation(latitude: 37.871853, longitude: -122.258423))
        CampusMapDataSource.getLocations()
        shortcutCollectionView.register(UINib(nibName: "ShortcutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        shortcutCollectionView.delegate = self
        shortcutCollectionView.dataSource = self
        detailViewController = DetailTableViewController()
        detailTableView.delegate = detailViewController
        detailTableView.dataSource = detailViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
    }
    
    func searchBarSearchButtonClicked(_ bar: UISearchBar) {
        campusMapView.removeAnnotations(campusMapView.annotations)
        bar.resignFirstResponder()
        guard let text = bar.text else { return }
        let locations = campusMapModel.search(for: text)
        for location in locations {
            if let annotation = location as? MKAnnotation {
            }
        }
        campusMapView.addAnnotations(locations)
    }
    
    func searchBarTextDidBeginEditing(_ bar: UISearchBar) {
     }
    
    func centerMapOnLocation(location: CLLocation) {
        let mapRadius: Double = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, mapRadius, mapRadius)
        campusMapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CampusMapModel.shortcutsAndIconNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = shortcutCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ShortcutCollectionViewCell {
            let cellImage = UIImage(named: CampusMapModel.shortcutsAndIconNames[indexPath.item].1)
            cell.shortcutImage.image = cellImage
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchString = CampusMapModel.shortcutsAndIconNames[indexPath.item].0
        searchBar.text = searchString
        searchBarSearchButtonClicked(searchBar)
    }
    
    private func registerMapAnnotationViews() {
        for identifier in CampusMapModel.shortcutToIconNames.keys {
            campusMapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let location = annotation as? Location {
            if let fileName = CampusMapModel.shortcutToIconNames[location.type] {
                if let image = UIImage(named: fileName), let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: location.type)
                {
                    var annotationImage = image.resize(toWidth: 20)
                    annotationImage = annotationImage!.resize(toHeight: 20)
                    annotationView.image = annotationImage
                    annotationView.canShowCallout = true
                    let rightButton = UIButton(type: .detailDisclosure)
                    annotationView.rightCalloutAccessoryView = rightButton
                    
                    return annotationView
                }
            }
        }
        return MKAnnotationView()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }


   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
