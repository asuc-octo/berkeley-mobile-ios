//
//  LibraryViewController.swift
//  
//
//  Created by Marisa Wong on 3/5/18.
//

import UIKit
import GoogleMaps
import Material
import Firebase
import MessageUI

fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)
fileprivate let kColorRed = UIColor.red

class LibraryViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, WeeklyTimesCellDelegate {
    
    var library: Library!
    var locationManager = CLLocationManager()
    var iconImages = [UIImage]()
    var libInfo = [String]()
    var types = [TappableInfoType]()
    var weeklyTimes = [String]()
    var daysOfWeek = [String]()
    var expandRow: Bool!
    
    @IBOutlet weak var libTitle: UILabel!
    @IBOutlet weak var libraryImage: UIImageView!
    @IBOutlet weak var libTableView: UITableView!
    @IBOutlet weak var libMap: GMSMapView!
    override func viewDidAppear(_ animated: Bool) {
        Analytics.logEvent("opened_library", parameters: ["name" : library.name])
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        libTitle.bringSubview(toFront: libraryImage)
        
        libTitle.text = library.name
        libTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        libTitle.numberOfLines = 0
        
        libTableView.separatorStyle = .none
        
        libraryImage.load(resource: library)
        iconImages.append(#imageLiteral(resourceName: "hours_2.0"))
        iconImages.append(#imageLiteral(resourceName: "phone_2.0"))
        iconImages.append(#imageLiteral(resourceName: "location_2.0"))
        
        libInfo.append(getLibraryStatusHours())
        libInfo.append(getLibraryPhoneNumber())
        libInfo.append(getLibraryLoc())
        
        types = [.none, .phone, .none]
        
        libTableView.delegate = self
        libTableView.dataSource = self

        expandRow = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let calendar = Calendar.current
        let dow = calendar.component(.weekday, from: Date())
        for i in 0...6 {
            var timeRange = "CLOSED ALL DAY"
            if let t = self.library.weeklyHours[(dow - 1 + i) % 7] {
                timeRange = dateFormatter.string(from:t.start) + " : " + dateFormatter.string(from:t.end)
            }
            weeklyTimes.append(timeRange)
        }
        
        var currDate = Date()
        for _ in 0...6 {
            let currDateString = calendar.component(.weekday, from: currDate)

            let nextDate = calendar.date(byAdding: .day, value: 1, to: currDate)
            
            switch currDateString {
            case 1:
                daysOfWeek.append("Sunday")
            case 2:
                daysOfWeek.append("Monday")
            case 3:
                daysOfWeek.append("Tuesday")
            case 4:
                daysOfWeek.append("Wednesday")
            case 5:
                daysOfWeek.append("Thursday")
            case 6:
                daysOfWeek.append("Friday")
            case 7:
                daysOfWeek.append("Saturday")
            default:
                daysOfWeek.append("")
            }
        
            currDate = nextDate!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func setUpMap() {
//        //Setting up map view
//        libMap.delegate = self
//        libMap.isMyLocationEnabled = true
//        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
//        self.libMap.camera = camera
//        self.libMap.frame = self.view.frame
//        self.libMap.isMyLocationEnabled = true
//        self.libMap.delegate = self
//        self.libMap.isUserInteractionEnabled = false
//        self.locationManager.startUpdatingLocation()
//
//        let kMapStyle =
//            "[" +
//                "{ \"featureType\": \"administrative\", \"elementType\": \"geometry\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, " +
//                "{ \"featureType\": \"poi\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, " +
//                "{ \"featureType\": \"road\", \"elementType\": \"labels.icon\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, " +
//                "{ \"featureType\": \"transit\", \"stylers\": [ {  \"visibility\": \"off\" } ] } " +
//        "]"
//
//        do {
//            // Set the map style by passing a valid JSON string.
//            self.libMap.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
//        } catch {
//            NSLog("The style definition could not be loaded: \(error)")
//        }
//
//        var lat = 37.0
//        var lon = -37.0
//        if let la = library?.latitude {
//            lat = la
//        }
//        if let lo = library?.longitude {
//            lon = lo
//        }
//        let marker = GMSMarker()
//
//        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//        marker.title = library?.name
//
//        let status = library?.isOpen;
//        if status! {
//            marker.icon = #imageLiteral(resourceName: "blueStop")
//            marker.snippet = "Open"
//        } else {
//            marker.icon = #imageLiteral(resourceName: "blueStop")
//            marker.snippet = "Closed"
//
//        }
//        marker.map = self.libMap
//
//    }
    
    func getLibraryStatusHours() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        var trivialDayStringsORDINAL = ["", "SUN","MON","TUE","WED","THU","FRI","SAT"]
        let dow = Calendar.current.component(.weekday, from: Date())
        var localOpeningTime = ""
        var localClosingTime = ""
        if let t = (self.library.weeklyHours[dow - 1]) {
            localOpeningTime = dateFormatter.string(from:t.start)
            localClosingTime = dateFormatter.string(from:t.end)
        }
        
        var timeRange:String = localOpeningTime + " to " + localClosingTime
        var status = "Closed"
        
        if (localOpeningTime == "" && localClosingTime == "") {
        timeRange = "Closed Today"
        } else {
            if library.isOpen {
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
        return 4
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandRow == true && indexPath.row == 0  {
            return 220
        } else if (indexPath.row == 3) {
            return 400
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func setUpMap(_ campResMap: GMSMapView) {
        //Setting up map view
        campResMap.delegate = self
        campResMap.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        campResMap.camera = camera
        campResMap.frame = self.view.frame
        campResMap.isMyLocationEnabled = true
        campResMap.isUserInteractionEnabled = false
        campResMap.delegate = self
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
            campResMap.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            //            print(error)
        }
        
        let lat = library.latitude!
        let lon = library.longitude!
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "blueStop")
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = library?.name
        marker.map = campResMap
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = libTableView.dequeueReusableCell(withIdentifier: "dropdown", for: indexPath) as! WeeklyTimesTableViewCell
            cell.delegate = self
            cell.icon.image = iconImages[indexPath.row]
            if self.library.isOpen {
                cell.day.text = "Open"
                cell.day.textColor = kColorGreen
            } else {
                cell.day.text = "Closed"
                cell.day.textColor = kColorRed
            }
            cell.time.text = weeklyTimes[0]
            cell.days = daysOfWeek
            cell.times = weeklyTimes
            if expandRow == true {
                cell.expandButton.setBackgroundImage(#imageLiteral(resourceName: "collapse"), for: .normal)
            } else {
                cell.expandButton.setBackgroundImage(#imageLiteral(resourceName: "expand"), for: .normal)
            }
            return cell
        } else if (indexPath.row == 3) {
            let campResInfoCell = tableView.dequeueReusableCell(withIdentifier: "librarymapTable", for: indexPath) as! LibraryMapTableViewCell
            setUpMap(campResInfoCell.mapView)
            return campResInfoCell
        } else {
            let libraryInfoCell = libTableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as! LibraryDetailCell
            
            libraryInfoCell.libraryIconImage.image = iconImages[indexPath.row]
            libraryInfoCell.libraryIconInfo.text = libInfo[indexPath.row]
            libraryInfoCell.libraryIconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
            libraryInfoCell.info = libraryInfoCell.libraryIconInfo.text
            libraryInfoCell.type = types[indexPath.row]
            libraryInfoCell.delegate = self
            return libraryInfoCell
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! WeeklyTimesTableViewCell
            expandRow(cell: cell)
        } else if let cell = tableView.cellForRow(at: indexPath) as? LibraryDetailCell {
            cell.didTap()
        }
    }
    
    // WeeklyTimesCellDelegate
    
    func expandRow(cell: WeeklyTimesTableViewCell) {
        expandRow = !expandRow
        libTableView.reloadData()
    }
}

extension LibraryViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
