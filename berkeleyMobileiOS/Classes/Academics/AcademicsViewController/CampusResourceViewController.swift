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

class CampusResourceViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var campResTitle: UILabel!
    @IBOutlet weak var campResImage: UIImageView!
    @IBOutlet weak var campResTableView: UITableView!
    
    var campusResource:CampusResource!
    var locationManager = CLLocationManager()
    
    var iconImages: [UIImage] = [
        UIImage(named:"hours_2.0.png")!,
        UIImage(named:"phone_2.0.png")!,
        UIImage(named:"location_2.0.png")!,
        UIImage(named:"info_2.0.png")!
    ]
    var types: [TappableInfoType] = [.none, .phone, .none, .none]
    
    var campResInfo = [String]()
    override func viewDidAppear(_ animated: Bool) {
        Analytics.logEvent("opened_resource", parameters: ["name" : campusResource.name])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        campResTitle.text = campusResource.name
        
        campResTableView.separatorStyle = .none

        campResImage.load(resource: campusResource)
        
        campResInfo.append((self.campusResource?.hours)!)
        campResInfo.append((self.campusResource?.phoneNumber)!)
        if let loc = campusResource.campusLocation {
            campResInfo.append(loc)
        } else {
            campResInfo.append("Call for location")
        }
        campResInfo.append((self.campusResource?.description)!)
        
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
        
        let lat = campusResource.latitude!
        let lon = campusResource.longitude!
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "blueStop")
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = campusResource?.name
        marker.map = campResMap
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
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return 200
        }
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 4 {
           let campResInfoCell = campResTableView.dequeueReusableCell(withIdentifier: "mapTable", for: indexPath) as! MapTableViewCell
            setUpMap(campResInfoCell.campusResourceMap)
            return campResInfoCell
        }
        
        let campResInfoCell = campResTableView.dequeueReusableCell(withIdentifier: "campusResourceDetail", for: indexPath) as! CampusResourceDetailCell
        
        campResInfoCell.campResIconImage.image = iconImages[indexPath.row]
        campResInfoCell.campResIconInfo.text = campResInfo[indexPath.row]
        campResInfoCell.campResIconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        campResInfoCell.info = campResInfoCell.campResIconInfo.text
        campResInfoCell.type = types[indexPath.row]
        campResInfoCell.delegate = self
        
        return campResInfoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CampusResourceDetailCell {
            cell.didTap()
        }
    }
}

extension CampusResourceViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

