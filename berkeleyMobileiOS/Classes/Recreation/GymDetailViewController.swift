//
//  GymDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 1/19/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import GoogleMaps

class GymDetailViewController: UIViewController, IBInitializable, CLLocationManagerDelegate, GMSMapViewDelegate, ResourceDetailProvider {
    var image: UIImage?
    
    
    @IBOutlet weak var gymInfoTableview: UITableView!
    //    @IBOutlet var gymStartEndTime: UILabel!
//    @IBOutlet var gymStatus: UILabel!
    @IBOutlet var gymInformationView: UIView!
    @IBOutlet var gymMap: GMSMapView!

    var iconImages = [UIImage]()
    var gymInfo = [String]()
    
    var locationManager = CLLocationManager()
    
    var gym: Gym!
    
    // MARK: - IBInitalizable
    typealias IBComponent = GymDetailViewController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent {
        return UIStoryboard.gym.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImages.append(#imageLiteral(resourceName: "hours_2.0"))
        iconImages.append(#imageLiteral(resourceName: "phone_2.0"))
        iconImages.append(#imageLiteral(resourceName: "website_2.0"))
        iconImages.append(#imageLiteral(resourceName: "location_2.0"))
        
        gymInfo.append(getGymStatusHours())
        gymInfo.append(getGymPhoneNumber())
        gymInfo.append(getGymWebsite())
        gymInfo.append(getGymLoc())

        gymInfoTableview.delegate = self
        gymInfoTableview.dataSource = self
        
        setUpMap()
//        setUpInformation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            marker.icon = #imageLiteral(resourceName: "blueStop")
        } else {
            marker.icon = #imageLiteral(resourceName: "blueStop")
        }
        
        marker.snippet = status
        marker.map = self.gymMap
        
    }
    
    
    @IBAction func openMap(_ sender: UIButton) {
        
        let lat = gym?.latitude!
        let lon = gym?.longitude!
    
        UIApplication.shared.open(NSURL(string: "https://www.google.com/maps/dir/Current+Location/" + String(describing: lat!) + "," + String(describing: lon!))! as URL,  options: [:], completionHandler: nil)
    }
    
    
    func getGymStatusHours() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        
        let localOpeningTime = dateFormatter.string(from: (self.gym?.openingTimeToday)!)
        let localClosingTime = dateFormatter.string(from: (self.gym?.closingTimeToday)!)
        
        let timeRange = localOpeningTime + " to " + localClosingTime
        
        var status = "Open"
        if (self.gym?.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
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
    
    func callGym() {
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
    
    func viewGymWebsite() {
        var website = ""

        //Hardcoding websites for gyms
        if (gym?.name.contains("Recreational"))! {
            website = "https://recsports.berkeley.edu/rsf/"

        } else if (gym?.name.contains("Stadium"))! {
            website = "https://recsports.berkeley.edu/stadium-fitness-center/"
        }

//        UIApplication.shared.open(NSURL(string: website)! as URL,  options: [:], completionHandler: nil)
        
//        guard let url = URL(string: website) else {
//            return //be safe
//        }
//
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
        
        
        let url = URL(string: website)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    func getMap() {
        let lat = gym?.latitude!
        let lon = gym?.longitude!
        
        UIApplication.shared.open(NSURL(string: "https://www.google.com/maps/dir/Current+Location/" + String(describing: lat!) + "," + String(describing: lon!))! as URL,  options: [:], completionHandler: nil)
    }
    
    func setData(_ gym: Gym) {
        self.gym = gym
        self.title = gym.name
    }
    
    
    // MARK: - ResourceDetailProvider
    static func newInstance() -> ResourceDetailProvider {
        return fromIB()
    }
    
    var resource: Resource
    {
        get { return gym }
        set
        {
            if viewIfLoaded == nil, gym == nil, let newGym = newValue as? Gym
            {
                gym = newGym
                title = gym.name
            }
        }
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
    
    var buttons: [UIButton] {
        return []
    }
    
    var contentSizeChangeHandler: ((ResourceDetailProvider) -> Void)? {
        get { return nil }
        set {}
    }
    
    /// Get the contentSize property of the internal UIScrollView.
    var contentSize: CGSize {
        let width = self.viewController.view.width
        let height = self.viewController.view.height
        return CGSize(width: width, height: height)
        
    }
    
    /// Get/Set the contentOffset property of the internal UIScrollView.
    var contentOffset: CGPoint {
        get { return CGPoint.zero }
        set {}
    }
    
    /// Set of setContentOffset method of the internal UIScrollView.
    func setContentOffset(_ offset: CGPoint, animated: Bool){}
}

extension GymDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoCell = gymInfoTableview.dequeueReusableCell(withIdentifier: "gymInfoCell", for: indexPath) as! GymInformationTableViewCell
        infoCell.iconImage.image = iconImages[indexPath.row]
        infoCell.iconInfo.text = gymInfo[indexPath.row]
        infoCell.iconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        return infoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print (indexPath.row)
        let cell  = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none

        if indexPath.row == 0 {
            // do nothing
        } else if indexPath.row == 1 {
            callGym()
            
        } else if indexPath.row == 2 {
            viewGymWebsite()
        } else if indexPath.row == 3 {
            getMap()
        }
    }

}
