//
//  GymDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 1/19/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import GoogleMaps

class GymDetailViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ResourceDetailProvider {
    
    @IBOutlet var gymStartEndTime: UILabel!
    @IBOutlet var gymStatus: UILabel!
    @IBOutlet var gymInformationView: UIView!
    @IBOutlet var gymMap: GMSMapView!
    var locationManager = CLLocationManager()
    
    var gym: Gym?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMap()
        setUpInformation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpInformation() {
            
            //Determining opening and closing times in PST
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")
            
            let localOpeningTime = dateFormatter.string(from: (self.gym?.openingTimeToday)!)
            let localClosingTime = dateFormatter.string(from: (self.gym?.closingTimeToday)!)
            
            self.gymStartEndTime.text = localOpeningTime + " to " + localClosingTime
            
            var status = "Open"
            if (self.gym?.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
                status = "Closed"
            }
            self.gymStatus.text = status
            if (status == "Open") {
                self.gymStatus.textColor = UIColor.green
            } else {
                self.gymStatus.textColor = UIColor.red
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func setUpMap() {
        //Setting up map view
        gymMap.delegate = self
        gymMap.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.gymMap.camera = camera
        self.gymMap.frame = self.view.frame
        self.gymMap.isMyLocationEnabled = true
        self.gymMap.delegate = self
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
            self.gymMap.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            //            print(error)
        }
        
        let lat = gym?.latitude!
        let lon = gym?.longitude!
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        marker.title = gym?.name
        
        var status = "Open"
        if (self.gym?.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
            status = "Closed"
        }
        
        if (status == "Open") {
            marker.icon = GMSMarker.markerImage(with: .green)
        } else {
            marker.icon = GMSMarker.markerImage(with: .red)
        }
        
        marker.snippet = status
        marker.map = self.gymMap
        
    }
    
    
    @IBAction func openMap(_ sender: UIButton) {
        let lat = gym?.latitude!
        let lon = gym?.longitude!
    
        UIApplication.shared.open(NSURL(string: "https://www.google.com/maps/dir/Current+Location/" + String(describing: lat!) + "," + String(describing: lon!))! as URL,  options: [:], completionHandler: nil)
    }
    

    @IBAction func callGym(_ sender: Any) {
        
        var number = ""
        
        //Hardcoding phone numbers for gyms
        if (gym?.name.contains("Recreational"))! {
            number = "5106438038"
            
        } else if (gym?.name.contains("Stadium"))! {
            number = "5106427796"
        }

        if let url = URL(string: "telprompt://\(number)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func viewGymWebsite(_ sender: Any) {
        
        var website = ""
        
        //Hardcoding websites for gyms
        if (gym?.name.contains("Recreational"))! {
            website = "https://recsports.berkeley.edu/rsf/"
            
        } else if (gym?.name.contains("Stadium"))! {
            website = "https://recsports.berkeley.edu/stadium-fitness-center/"
        }
        
        UIApplication.shared.open(NSURL(string: website)! as URL,  options: [:], completionHandler: nil)
        
    }
    
    
    func setData(_ gym: Gym) {
        self.gym = gym
        
        self.title = gym.name
        
        
    }
    var text1: String? {
        return nil
    }
    var text2: String? {
        return nil
    }
    var viewController: UIViewController {
        return self
    }
    var imageURL: URL? {
        return gym?.imageURL
    }
    
    var resetOffsetOnSizeChanged = false
    
    var buttons: [UIButton]
    {
        return []
    }
    
    var contentSizeChangeHandler: ((ResourceDetailProvider) -> Void)?
        {
        get { return nil }
        set {}
    }
    
    /// Get the contentSize property of the internal UIScrollView.
    var contentSize: CGSize
    {
        let width = self.viewController.view.width
        let height = gymInformationView.height + gymMap.height
        return CGSize(width: width, height: height)
        
    }
    
    /// Get/Set the contentOffset property of the internal UIScrollView.
    var contentOffset: CGPoint
        {
        get { return CGPoint.zero }
        set {}
    }
    
    /// Set of setContentOffset method of the internal UIScrollView.
    func setContentOffset(_ offset: CGPoint, animated: Bool){}
    


    

}
