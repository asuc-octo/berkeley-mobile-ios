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
fileprivate let kBookingURL = "berkeley.libcal.com"
fileprivate let kBookingStr = "Book Study Rooms"

class LibraryViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, WeeklyTimesCellDelegate {
    
    var library: Library!
    var locationManager = CLLocationManager()
    var weeklyTimes = [String]()
    var daysOfWeek = [String]()
    var expandRow: Bool!
    
    var cells: [AcademicDetailCellTypes] = [
        .weekly,
        .phone,
        .location,
        .website
    ]
    var libInfo = [String?]()
    
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
        
        for i in 0..<cells.count {
            switch cells[i] {
            case .weekly:
                libInfo.append("")
                initWeeklyTimes()
            case .phone:
                libInfo.append(library.phoneNumber)
            case .location:
                libInfo.append(library.campusLocation ?? "UC Berkeley")
            case .website:
                libInfo.append(kBookingURL)
            default:
                libInfo.append(nil)
            }
            
            if libInfo[i].isNil {
                cells[i] = .none
            }
        }
        
        cells = cells.filter { $0 != .none }
        libInfo = libInfo.filter { !$0.isNil }
        
        libTableView.delegate = self
        libTableView.dataSource = self

        expandRow = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initWeeklyTimes() {
        expandRow = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let calendar = Calendar.current
        let dow = Date().weekday()
        for i in 0...6 {
            var timeRange = "CLOSED ALL DAY"
            if let t = library.weeklyHours[(dow + i) % 7] {
                timeRange = dateFormatter.string(from:t.start) + " : " + dateFormatter.string(from:t.end)
            }
            weeklyTimes.append(timeRange)
            daysOfWeek.append(calendar.weekdaySymbols[(dow + i) % 7])
        }
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
}



extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count + 1
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == cells.count {
            return 400
        } else if expandRow == true && cells[indexPath.row] == .weekly  {
            return 220
        }  else {
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
        
        let lat = library.latitude ?? 0
        let lon = library.longitude ?? 0
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "blueStop")
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = library?.name
        marker.map = campResMap
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == cells.count {
            let campResInfoCell = tableView.dequeueReusableCell(withIdentifier: "librarymapTable", for: indexPath) as! LibraryMapTableViewCell
            setUpMap(campResInfoCell.mapView)
            return campResInfoCell
        } else if cells[indexPath.row] == .weekly {
            let cell = libTableView.dequeueReusableCell(withIdentifier: "dropdown", for: indexPath) as! WeeklyTimesTableViewCell
            cell.delegate = self
            cell.icon.image = cells[indexPath.row].icon ?? UIImage(named:"info_2.0.png")
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
        } else {
            let libraryInfoCell = libTableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as! LibraryDetailCell
            
            libraryInfoCell.libraryIconImage.image = cells[indexPath.row].icon ?? UIImage(named:"info_2.0.png")
            libraryInfoCell.libraryIconInfo.text = cells[indexPath.row] == .website ? kBookingStr : libInfo[indexPath.row]
            libraryInfoCell.libraryIconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
            libraryInfoCell.info = libInfo[indexPath.row]
            libraryInfoCell.type = cells[indexPath.row].tappableType
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
