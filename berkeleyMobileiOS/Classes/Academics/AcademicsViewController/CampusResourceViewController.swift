//
//  CampusResourceViewController.swift
//
//
//  Created by Marisa Wong on 3/5/18.
//

import UIKit
import Material
import GoogleMaps
import Firebase
import MessageUI

fileprivate let kAppointmentMessage = "By Appointment"
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)
fileprivate let kColorRed = UIColor.red

class CampusResourceViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, WeeklyTimesCellDelegate {
    
    @IBOutlet weak var campResTitle: UILabel!
    @IBOutlet weak var campResImage: UIImageView!
    @IBOutlet weak var campResTableView: UITableView!
    
    var campusResource:CampusResource!
    var locationManager = CLLocationManager()
    
    var expandRow: Bool!
    var weeklyTimes = [String]()
    var daysOfWeek = [String]()
    
    var cells: [AcademicDetailCellTypes] = [
        .hours,
        .phone,
        .email,
        .location,
        .description
    ]
    var campResInfo: [String?] = []
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.logEvent("opened_resource", parameters: ["name" : campusResource.name])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        campResTitle.text = campusResource.name
        
        campResTableView.separatorStyle = .none

        campResImage.load(resource: campusResource)
        
        for i in 0..<cells.count {
            switch cells[i] {
            case .hours:
                if campusResource.byAppointment {
                    campResInfo.append(kAppointmentMessage)
                } else if campusResource.weeklyHours.isNil {
                    campResInfo.append(nil)
                } else {
                    cells[i] = .weekly
                    campResInfo.append("")
                    initWeeklyTimes()
                }
            case .phone:
                campResInfo.append(campusResource.phoneNumber)
            case .email:
                campResInfo.append(campusResource.email)
            case .location:
                campResInfo.append(campusResource.campusLocation ?? "Contact for location")
            case .description:
                if !campusResource.description.isNil && campusResource.description!.count > 0 {
                    campResInfo.append(campusResource.description)
                }
                campResInfo.append(nil)
            default:
                campResInfo.append(nil)
            }
            
            if campResInfo[i].isNil {
                cells[i] = .none
            }
        }
        
        cells = cells.filter { $0 != .none }
        campResInfo = campResInfo.filter { !$0.isNil }
        
        campResTableView.delegate = self
        campResTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let lat = campusResource.latitude ?? 0
        let lon = campusResource.longitude ?? 0
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "blueStop")
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = campusResource?.name
        marker.map = campResMap
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
            if let t = campusResource.weeklyHours![(dow + i) % 7] {
                timeRange = dateFormatter.string(from:t.start) + " : " + dateFormatter.string(from:t.end)
            }
            weeklyTimes.append(timeRange)
            daysOfWeek.append(calendar.weekdaySymbols[(dow + i) % 7])
        }
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
extension CampusResourceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == cells.count {
            return 200
        } else if expandRow == true && cells[indexPath.row] == .weekly  {
            return 220
        }
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == cells.count {
           let campResInfoCell = campResTableView.dequeueReusableCell(withIdentifier: "mapTable", for: indexPath) as! MapTableViewCell
            setUpMap(campResInfoCell.campusResourceMap)
            return campResInfoCell
        } else if cells[indexPath.row] == .weekly {
            let cell = campResTableView.dequeueReusableCell(withIdentifier: "dropdown", for: indexPath) as! WeeklyTimesTableViewCell
            cell.delegate = self
            cell.icon.image = cells[indexPath.row].icon ?? UIImage(named:"hours_2.0.png")
            if self.campusResource.isOpen {
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
            let campResInfoCell = campResTableView.dequeueReusableCell(withIdentifier: "campusResourceDetail", for: indexPath) as! CampusResourceDetailCell
            
            campResInfoCell.campResIconImage.image = cells[indexPath.row].icon ?? UIImage(named:"info_2.0.png")
            campResInfoCell.campResIconInfo.text = campResInfo[indexPath.row]
            campResInfoCell.campResIconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
            campResInfoCell.info = campResInfoCell.campResIconInfo.text
            campResInfoCell.type = cells[indexPath.row].tappableType
            campResInfoCell.delegate = self
            
            return campResInfoCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < cells.count && cells[indexPath.row] == .weekly {
            let cell = tableView.cellForRow(at: indexPath) as! WeeklyTimesTableViewCell
            expandRow(cell: cell)
        } else if let cell = tableView.cellForRow(at: indexPath) as? CampusResourceDetailCell {
            cell.didTap()
        }
    }
    
    // WeeklyTimesCellDelegate
    
    func expandRow(cell: WeeklyTimesTableViewCell) {
        expandRow = !expandRow
        campResTableView.reloadData()
    }
}

extension CampusResourceViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

