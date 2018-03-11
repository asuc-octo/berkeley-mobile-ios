//
//  ResourceDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/4/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit
import GoogleMaps

class ResourceDetailViewController: UIViewController, CLLocationManager, GMSMapViewDelegate {
    
    @IBOutlet weak var resourceImage: UIImageView!
    @IBOutlet weak var resourceTableView: UITableView!
    @IBOutlet var resourceMap: GMSMapView!
    
    var 
    var locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMap()
        // Do any additional setup after loading the view.
    }

    func setUpMap() {
        //Setting up map view
        resourceMap.delegate = self
        resourceMap.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.resourceMap.camera = camera
        self.resourceMap.frame = self.view.frame
        self.resourceMap.isMyLocationEnabled = true
        self.resourceMap.delegate = self
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
            self.resourceMap.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            //            print(error)
        }
        
        
        let lat = resource?.latitude!
        let lon = resource?.longitude!
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        marker.title = resource?.name
        
        var status = "Open"
        if (self.resource?.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
            status = "Closed"
        }
        
        if (status == "Open") {
            marker.icon = #imageLiteral(resourceName: "blueStop")
        } else {
            marker.icon = #imageLiteral(resourceName: "blueStop")
        }
        
        marker.snippet = status
        marker.map = self.resourceMap
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
