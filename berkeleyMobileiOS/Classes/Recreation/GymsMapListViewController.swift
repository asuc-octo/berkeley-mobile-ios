//
//  GymsMapListViewController.swift
//  
//
//  Created by Sampath Duddu on 1/2/17.
//
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class GymsMapListViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var gymsMapView: GMSMapView!
    
    @IBOutlet var gymsTableView: UITableView!
    
    @IBOutlet var gymsSearchBar: UISearchBar!
    
    var gyms = [CLLocation(latitude: 37.871856, longitude: -122.258423),
                     CLLocation(latitude: 37.872545, longitude: -122.256423)
    ]
    
    var locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSegmentedControl()
        
        gymsSearchBar.isHidden = true
        gymsTableView.isHidden = true
        gymsMapView.isHidden = false
        
        gymsTableView.delegate = self
        gymsTableView.dataSource = self
        
        //Setting up map view
        gymsMapView.delegate = self
        gymsMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.gymsMapView.camera = camera
        self.gymsMapView.frame = self.view.frame
        self.gymsMapView.isMyLocationEnabled = true
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
            self.gymsMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            print(error)
        }
        
         plotLibraries()


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Plots the location of gyms on map view
    func plotLibraries() {
        
        var minLat = 1000.0
        var maxLat = -1000.0
        var minLon = 1000.0
        var maxLon = -1000.0
        
        for gym in gyms {
            
            let marker = GMSMarker()
            let lat = gym.coordinate.latitude
            let lon = gym.coordinate.longitude
            
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.title = "Sydney"
            marker.snippet = "Australia"
            
            marker.map = self.gymsMapView
            
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
        
        //Sets the bounds of the map based on the coordinates
        let southWest = CLLocationCoordinate2DMake(minLat,minLon)
        let northEast = CLLocationCoordinate2DMake(maxLat,maxLon)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        gymsMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        
    }

    //Segmented control methods
    func setSegmentedControl() {
        
        //Create a segmented control to use on the navigation bar
        let segment: UISegmentedControl = UISegmentedControl(items:
            [" Map ", "List "])
        segment.sizeToFit()
        segment.tintColor = UIColor.blue
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(LibraryMapViewController.segmentControlValueChanged), for:.valueChanged)
        self.navigationItem.titleView = segment
    }
    
    //Hide map and list dependent on selected value
    func segmentControlValueChanged(sender: UISegmentedControl!) {
        
        if sender.selectedSegmentIndex == 0 {
            gymsSearchBar.isHidden = true
            gymsTableView.isHidden = true
            gymsMapView.isHidden = false
        } else {
            gymsSearchBar.isHidden = false
            gymsTableView.isHidden = false
            gymsMapView.isHidden = true
        }
        
    }
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gym") as! GymCell
        cell.gymName.text = "Hearst Gym"
        cell.gymStatus.text = "OPEN"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    

}
