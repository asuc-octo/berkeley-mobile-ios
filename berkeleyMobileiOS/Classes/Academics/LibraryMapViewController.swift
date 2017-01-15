//
//  LibraryMapViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/17/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class LibraryMapViewController: UIViewController, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var librariesTableView: UITableView!
    @IBOutlet var librariesSearchBar: UISearchBar!
    @IBOutlet var librariesMapView: GMSMapView!

    var libraries = [Library]()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSegmentedControl()
        
        librariesSearchBar.isHidden = true
        librariesTableView.isHidden = true
        librariesMapView.isHidden = false
        
        librariesTableView.delegate = self
        librariesTableView.dataSource = self
        
        //Setting up map view
        librariesMapView.delegate = self
        librariesMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.librariesMapView.camera = camera
        self.librariesMapView.frame = self.view.frame
        self.librariesMapView.isMyLocationEnabled = true
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
             self.librariesMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            print(error)
        }

        plotLibraries()
        
    }
    
    //Plots the location of libraries on map view
    func plotLibraries() {

        var minLat = 1000.0
        var maxLat = -1000.0
        var minLon = 1000.0
        var maxLon = -1000.0
        
        for library in libraries {
            
            let marker = GMSMarker()
            if ((library.latitude == nil) || (library.longitude == nil)) {
                continue
            }
            let lat = library.latitude!
            let lon = library.longitude!
            
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.title = library.name
            
            let status = getLibraryStatus(library: library)
            if (status == "NIL") {
                continue
            }
            
            marker.snippet = status
            marker.map = self.librariesMapView
            
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
        librariesMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "library") as! LibraryCell
        
        let library = libraries[indexPath.row]
        cell.libraryName.text = library.name
        
        let status = getLibraryStatus(library: library)
        if (status == "NIL") {
            cell.height = 0.0
            return cell
        }
        
        cell.libraryStatus.text = status
        if (status == "OPEN") {
            cell.libraryStatus.textColor = UIColor.green
        } else {
            cell.libraryStatus.textColor = UIColor.red
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.librariesMapView?.animate(to: camera)
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
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
            librariesSearchBar.isHidden = true
            librariesTableView.isHidden = true
            librariesMapView.isHidden = false
        } else {
            librariesSearchBar.isHidden = false
            librariesTableView.isHidden = false
            librariesMapView.isHidden = true
        }
        
    }
    
    func getLibraryStatus(library: Library) -> String {
        
        //Determining Status of library
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: todayDate as Date)
        let weekDay = myComponents.weekday! - 1
        
        if (library.weeklyClosingTimes[weekDay] == nil) {
            return "NIL"
        }
        
        var status = "CLOSED"
        if (library.weeklyClosingTimes[weekDay]!.compare(todayDate as Date) == .orderedAscending) {
            status = "OPEN"
        }
        
        return status
    }
    

    
    


}
