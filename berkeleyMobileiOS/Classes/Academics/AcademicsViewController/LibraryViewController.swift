//
//  LibraryViewController.swift
//  
//
//  Created by Marisa Wong on 3/5/18.
//

import UIKit
import GoogleMaps
import Material

class LibraryViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var library: Library!
    var locationManager = CLLocationManager()
    var iconImages = [UIImage]()
    var libInfo = [String]()
    
    @IBOutlet weak var libTitle: UILabel!
    @IBOutlet weak var libraryImage: UIImageView!
    @IBOutlet weak var libTableView: UITableView!
    @IBOutlet weak var libMap: GMSMapView!
    
    override func viewDidLoad() {
        setUpMap()
        libTitle.bringSubview(toFront: libraryImage)
        
        libTitle.text = library.name
        libTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        libTitle.numberOfLines = 0
        
        libTableView.separatorStyle = .none
        
        if let data = try? Data(contentsOf: library.imageURL!)
        {
            let image: UIImage = UIImage(data: data)!
            libraryImage.image = image
        }
        
        iconImages.append(#imageLiteral(resourceName: "hours_2.0"))
        iconImages.append(#imageLiteral(resourceName: "phone_2.0"))
        iconImages.append(#imageLiteral(resourceName: "location_2.0"))
        
        libInfo.append(getLibraryStatusHours())
        libInfo.append(getLibraryPhoneNumber())
        libInfo.append(getLibraryLoc())
        
        libTableView.delegate = self
        libTableView.dataSource = self

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpMap() {
        //Setting up map view
        libMap.delegate = self
        libMap.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.libMap.camera = camera
        self.libMap.frame = self.view.frame
        self.libMap.isMyLocationEnabled = true
        self.libMap.delegate = self
        self.libMap.isUserInteractionEnabled = false
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
            self.libMap.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }
        
        var lat = 37.0
        var lon = -37.0
        if let la = library?.latitude {
            lat = la
        }
        if let lo = library?.longitude {
            lon = lo
        }
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = library?.name
        
        let status = library?.isOpen;
        if status! {
            marker.icon = #imageLiteral(resourceName: "blueStop")
            marker.snippet = "Open"
        } else {
            marker.icon = #imageLiteral(resourceName: "blueStop")
            marker.snippet = "Closed"
            
        }
        marker.map = self.libMap
        
    }
    
    func getLibraryStatusHours() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        var trivialDayStringsORDINAL = ["", "SUN","MON","TUE","WED","THU","FRI","SAT"]
        let dow = Calendar.current.component(.weekday, from: Date())
        let translateddow = (dow - 2 + 7) % 7
        var localOpeningTime = ""
        var localClosingTime = ""
        if let t = (self.library?.weeklyOpeningTimes[translateddow]) {
        localOpeningTime = dateFormatter.string(from:t)
        }
        if let t = (self.library?.weeklyClosingTimes[translateddow]) {
        localClosingTime = dateFormatter.string(from:t)
        }
        
        var timeRange:String = localOpeningTime + " to " + localClosingTime
        var status = "Closed"
        
        if (localOpeningTime == "" && localClosingTime == "") {
        timeRange = "Closed Today"
        } else {
        let openTime = (self.library!.weeklyOpeningTimes[translateddow])!
        let closeTime = (self.library!.weeklyClosingTimes[translateddow])!
        if (openTime < Date() && closeTime > Date()) {
        status = "Open"
        }
        }
        
        var timeInfo = status + "    " + timeRange
        if (timeRange == "Closed Today") {
        timeInfo = timeRange
        }
        return timeInfo
    }
    
    func getLibraryPhoneNumber() -> String {
        return (self.library?.phoneNumber)!
    }
    
    func getLibraryWebsite() -> String {
        //        return library.
        return "marisawong.comlmao"
        
    }
    
    
    func getLibraryLoc() -> String {
        if let loc = library.campusLocation {
            return loc
        } else {
            return "UC Berkeley"
        }
    }
}
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let libraryInfoCell = libTableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as! LibraryDetailCell
            
        libraryInfoCell.libraryIconImage.image = iconImages[indexPath.row]
        libraryInfoCell.libraryIconInfo.text = libInfo[indexPath.row]
        libraryInfoCell.libraryIconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        return libraryInfoCell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
            
        if indexPath.row == 1 {
           // callLibrary()
        }
        else if indexPath.row == 2 {
            //getMap()
        }
    }
        

}
