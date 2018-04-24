//
//  SpecificGymViewController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/27/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//
import GoogleMaps
import UIKit
import Firebase
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)
fileprivate let kColorRed = UIColor.red
class SpecificGymViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var gym: Gym! 
    
    @IBOutlet var gymMap: GMSMapView!
    @IBOutlet weak var gymImage: UIImageView!
    
    @IBOutlet weak var gymInfoTableview: UITableView!
    var locationManager = CLLocationManager()

    @IBOutlet weak var gymTitle: UILabel!
    
    var iconImages = [UIImage]()
    var gymInfo = [String]()
    override func viewDidAppear(_ animated: Bool) {
        Analytics.logEvent("opened_gym", parameters: ["name": gym.name])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if gym.name == "Recreational Sports Facility (RSF)" {
            gymImage.image = #imageLiteral(resourceName: "rsf")
        } else {
            gymImage.load(resource: gym)
        }
        gymTitle.text = gym.name
     
        iconImages.append(#imageLiteral(resourceName: "hours_2.0"))
        iconImages.append(#imageLiteral(resourceName: "phone_2.0"))
        iconImages.append(#imageLiteral(resourceName: "location_2.0"))
        iconImages.append(#imageLiteral(resourceName: "info_2.0"))
        
        gymInfo.append(getGymStatusHours())
        gymInfo.append(getGymPhoneNumber())
        gymInfo.append(getGymWebsite())
        gymInfo.append(getGymLoc())
        
        gymInfoTableview.delegate = self
        gymInfoTableview.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    func setUpMap(_ gymMap: GMSMapView) {
        //Setting up map view
        gymMap.delegate = self
        gymMap.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        gymMap.camera = camera
        gymMap.frame = self.view.frame
        gymMap.isMyLocationEnabled = true
        gymMap.delegate = self
        gymMap.isUserInteractionEnabled = false
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
            gymMap.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
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
            marker.icon = #imageLiteral(resourceName: "blueStop")
        } else {
            marker.icon = #imageLiteral(resourceName: "blueStop")
        }
        
        marker.snippet = status
        marker.map = gymMap
        
    }
    
    func getGymStatusHours() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        
        //Test date formatter
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm"
        df.timeZone = TimeZone(abbreviation: "PST")
        
        let localOpeningTime = dateFormatter.string(from: (self.gym?.openingTimeToday)!)
        let localClosingTime = dateFormatter.string(from: (self.gym?.closingTimeToday)!)
        
        let timeRange = localOpeningTime + " to " + localClosingTime
        
        var status = "Open"
        
        if !self.gym.isOpen {
            status = "Closed"
        }
        let timeInfo = status + "    " + timeRange
        return timeInfo
    }
    
    
    func getGymPhoneNumber() -> String {
        var number = ""
        if (gym?.name.contains("Recreational"))! {
            number = "(510) 643-8038"
            
        } else if (gym?.name.contains("Stadium"))! {
            number = "(510) 642-7796"
        }
        return number
    }
    
    func getGymWebsite() -> String{
        var website = ""
        
        //Hardcoding websites for gyms
        if (gym?.name.contains("Recreational"))! {
            website = "recsports.berkeley.edu/rsf/"
            
        } else if (gym?.name.contains("Stadium"))! {
            website = "recsports.berkeley.edu/stadium-fitness-center/"
        }
        return website
    }
    
    func getGymLoc() -> String {
        let addr = gym?.address
        let addrArray = addr?.components(separatedBy: ",")
        return addrArray![0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension SpecificGymViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 4 {
            let infoCell = gymInfoTableview.dequeueReusableCell(withIdentifier: "mapTable", for: indexPath) as! MapTableViewCell
            setUpMap(infoCell.campusResourceMap)
            return infoCell
        }
        
        let infoCell = gymInfoTableview.dequeueReusableCell(withIdentifier: "gymInfoCell", for: indexPath) as! GymInformationTableViewCell
        
        infoCell.iconImage.image = iconImages[indexPath.row]
        infoCell.iconInfo.text = gymInfo[indexPath.row]
        infoCell.iconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        return infoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        
        if indexPath.row == 1 {
//            callGym()
        } else if indexPath.row == 2 {
//            viewGymWebsite()
        } else if indexPath.row == 3 {
//            getMap()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return 300
        }
        return 55
    }
}
