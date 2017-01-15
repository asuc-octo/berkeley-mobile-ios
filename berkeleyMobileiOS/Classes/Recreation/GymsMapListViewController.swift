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
    
    var gymsMain = [Gym]()
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
        
        for gym in gymsMain {
            
            let marker = GMSMarker()
            var lat = 0.0
            var lon = 0.0
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(gym.address) { (placemarks, error) in
                if let placemarks = placemarks {
                    if placemarks.count != 0 {
                        
                        //Getting coordinates from geocoder
                        let coordinates = placemarks.first!.location
                        lat = (coordinates?.coordinate.latitude)!
                        lon = (coordinates?.coordinate.longitude)!
                        
                        // Setting attributes of marker
                        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        marker.title = gym.name
                        var status = "OPEN"
                        if (gym.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
                            status = "CLOSED"
                        }
                        
                        marker.snippet = status
                        marker.map = self.gymsMapView
                        
                        //Helps to adjust map at the end of plotting
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
                    self.gymsMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                }
            }
        }
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
        let gym = gymsMain[indexPath.row]
        cell.gymName.text = gym.name
        var status = "OPEN"
        if (gym.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
            status = "CLOSED"
        }
        cell.gymStatus.text = status
        if (status == "OPEN") {
            cell.gymStatus.textColor = UIColor.green
        } else {
            cell.gymStatus.textColor = UIColor.red
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gymsMain.count
    }

}
