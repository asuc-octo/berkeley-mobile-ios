//
//  CampusResourceMapListViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 3/18/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps
import RealmSwift

class CampusResourceMapListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var campusResources:[CampusResource]?
    var favoriteCampusResources = [String]()
    
    var locationManager = CLLocationManager()
    var realm = try! Realm()

    @IBOutlet var campusResourcesTableView: UITableView!
    @IBOutlet var campusResourcesMapView: GMSMapView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setSegmentedControl()
        
        campusResourcesTableView.isHidden = true
        campusResourcesMapView.isHidden = false
        
        campusResourcesTableView.delegate = self
        campusResourcesTableView.dataSource = self
        
        //Setting up map view
        campusResourcesMapView.delegate = self
        campusResourcesMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.campusResourcesMapView.camera = camera
        self.campusResourcesMapView.frame = self.view.frame
        self.campusResourcesMapView.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        let kMapStyle =
            "[" +
                "{ \"featureType\": \"administrative\", \"elementType\": \"geometry\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, " +
                "{ \"featureType\": \"poi\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, " +
                "{ \"featureType\": \"road\", \"elementType\": \"labels.icon\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, " +
                "{ \"featureType\": \"transit\", \"stylers\": [ {  \"visibility\": \"off\" } ] } " +
        "]"
        
        do {
            // Set the map style by passing a valid JSON string.
            self.campusResourcesMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            print(error)
        }
        
        plotCampusResources()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAndSetFavoriteCampusResources()
        campusResourcesTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "campusResource") as! CampusResourceCell
        let campusResource = campusResources?[indexPath.row]
        
        cell.name.text = campusResource?.name
        cell.status.text = campusResource?.hours
        
        // For favoriting
        if (campusResource?.isFavorited == true) {
            cell.favoriteButton.setImage(UIImage(named:"heart-filled"), for: .normal)
        } else {
            cell.favoriteButton.setImage(UIImage(named:"heart"), for: .normal)
        }
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(self.toggleCampusResourceFavoriting(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (campusResources?.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CampusResourceDetailSegue", sender: indexPath.row)
    }
    
    //Plots the location of campus resources on map view
    func plotCampusResources() {
        
        var minLat = 1000.0
        var maxLat = -1000.0
        var minLon = 1000.0
        var maxLon = -1000.0
        
        for campusResource in campusResources! {
            
            let marker = GMSMarker()
            if ((campusResource.latitude == nil) || (campusResource.longitude == nil)) {
                continue
            }
            let lat = campusResource.latitude!
            let lon = campusResource.longitude!
            
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.title = campusResource.name
            marker.map = self.campusResourcesMapView
            
            if (lat < minLat) {
                minLat = lat
            }
            
            if (lat > maxLat) {
                maxLat = lat
            }
            
            if (lon < minLon) {
                minLon = lon
            }
            
            if (lon > maxLon) {
                maxLon = lon
            }
        }
        
        //Sets the bounds of the map based on the coordinates plotted
        let southWest = CLLocationCoordinate2DMake(minLat,minLon)
        let northEast = CLLocationCoordinate2DMake(maxLat,maxLon)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        campusResourcesMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        
    }

    
    //Segmented control methods
    func setSegmentedControl() {
        
        //Create a segmented control to use on the navigation bar
        let segment: UISegmentedControl = UISegmentedControl(items:
            [" Map ", "List "])
        segment.sizeToFit()
        segment.tintColor = UIColor.blue
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(CampusResourceMapListViewController.segmentControlValueChanged), for:.valueChanged)
        self.navigationItem.titleView = segment
    }
    
    //Hide map and list dependent on selected value
    func segmentControlValueChanged(sender: UISegmentedControl!) {
        
        if sender.selectedSegmentIndex == 0 {
//            gymsSearchBar.isHidden = true
            campusResourcesTableView.isHidden = true
            campusResourcesMapView.isHidden = false
        } else {
//            gymsSearchBar.isHidden = false
            campusResourcesTableView.isHidden = false
            campusResourcesMapView.isHidden = true
        }
        
    }
    
    //Favoriting
    func toggleCampusResourceFavoriting(sender: UIButton) {
        
        let row = sender.tag
        let selectedCampusResource = campusResources?[row]
        selectedCampusResource?.isFavorited = !(selectedCampusResource?.isFavorited)!
        self.campusResourcesTableView.reloadData()
        
        //Realm adding and deleting favorite campus resources
        let favCampusResource = FavoriteCampusResource()
        favCampusResource.name = (selectedCampusResource?.name)!
        
        if (selectedCampusResource?.isFavorited)! {
            try! realm.write {
                realm.add(favCampusResource)
            }
        } else {
            let campusResources = realm.objects(FavoriteCampusResource.self)
            for campusResource in campusResources {
                if campusResource.name == selectedCampusResource?.name {
                    try! realm.write {
                        realm.delete(campusResource)
                    }
                }
            }
        }
        
    }
    
    func getAndSetFavoriteCampusResources() {
        self.favoriteCampusResources.removeAll()
        let campusResources = realm.objects(FavoriteCampusResource.self)
        for campusResource in campusResources {
            self.favoriteCampusResources.append(campusResource.name)
        }
        
        for campusResource in self.campusResources! {
            if self.favoriteCampusResources.contains(campusResource.name) {
                campusResource.isFavorited = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "CampusResourceDetailSegue") {
            let selectedIndex = sender as! Int
            let selectedCampusResource = self.campusResources?[selectedIndex]
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            let campusResourceDetailVC = segue.destination as! CampusResourceDetailViewController
            
            campusResourceDetailVC.campusResource = selectedCampusResource
            
        }
        
    }

}

class FavoriteCampusResource: Object {
    dynamic var name = ""
}
