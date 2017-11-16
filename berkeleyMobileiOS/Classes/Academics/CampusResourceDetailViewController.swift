//
//  CampusResourceDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 4/1/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import MessageUI

class CampusResourceDetailViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, ResourceDetailProvider, IBInitializable {
    
    @IBOutlet weak var campusStack: UIStackView!
//    @IBOutlet var campusResDetailView: UIView!
   
    @IBOutlet var campusResStartEndTime: UILabel!
    @IBOutlet var campusResMapView: GMSMapView!
    
    @IBOutlet weak var campusResDetailTableview: UITableView!
    @IBOutlet weak var LibraryTableView: UITableView!
    
    
    var campusResource:CampusResource!
    var locationManager = CLLocationManager()
    
    var iconImages = [UIImage]()
    var campResInfo = [String]()
    
    // MARK: - IBInitializable
    typealias IBComponent = CampusResourceDetailViewController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent 
    {
        return UIStoryboard.academics.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = campusResource?.name
    
        iconImages.append(UIImage(named: "hours.png")!)
        iconImages.append(UIImage(named: "phone.png")!)
//        iconImages.append(UIImage(named: "website.png")!)
        iconImages.append(UIImage(named: "loc.png")!)
        
        campResInfo.append((self.campusResource?.hours)!)
        campResInfo.append((self.campusResource?.phoneNumber)!)
//        campResInfo.append((self.campusResource?.notes)!)
        if let loc = campusResource.campusLocation {
            campResInfo.append(loc)
        } else {
            campResInfo.append("Call for location")
        }
//        campResInfo.append((self.campusResource?.campusLocation)!)
        
        campusResDetailTableview.delegate = self
        campusResDetailTableview.dataSource = self
        
        setUpMap()
        setUpInformation()
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    


    func setUpInformation() {
//        self.campusResStartEndTime.text = self.campusResource.hours
//
//        // For favoriting
//        if (campusResource.isFavorited) {
//            self.campusResFavoriteButton.setImage(#imageLiteral(resourceName: "heart-large-filled"), for: .normal)
//        } else {
//            self.campusResFavoriteButton.setImage(#imageLiteral(resourceName: "heart-large"), for: .normal)
//        }
//        self.campusResStartEndTime.text = self.campusResource.hours
        
        // For favoriting
        
        return
    }

    func setUpMap() {
        //Setting up map view
        campusResMapView.delegate = self
        campusResMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.campusResMapView.camera = camera
        self.campusResMapView.frame = self.view.frame
        self.campusResMapView.isMyLocationEnabled = true
        self.campusResMapView.isUserInteractionEnabled = false
        self.campusResMapView.delegate = self
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
            self.campusResMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
            //            print(error)
        }
        
        let lat = campusResource.latitude!
        let lon = campusResource.longitude!
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: UIColor(hex: "022E81"))
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = campusResource?.name
        marker.map = self.campusResMapView
    }
    
//    @IBAction func callCampusResource(_ sender: UIButton) {
//        let numberArray = self.campusResource?.phoneNumber?.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
//        var number = ""
//        for n in numberArray! {
//            number += n
//        }
//
//        if let url = URL(string: "telprompt://\(number)") {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }

    func callCampRes() {
        let numberArray = self.campusResource?.phoneNumber?.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        var number = ""
        for n in numberArray! {
            number += n
        }
        
        if let url = URL(string: "telprompt://\(number)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func favoriteCampusResource(_ sender: UIButton) {
        guard let campusResource = self.campusResource else {
            return
        }
        campusResource.isFavorited = !campusResource.isFavorited
        FavoriteStore.shared.update(campusResource)
        
        if campusResource.isFavorited {
            (sender ).setImage(#imageLiteral(resourceName: "heart-large-filled"), for: .normal)
        } else {
            (sender ).setImage(#imageLiteral(resourceName: "heart-large"), for: .normal)
        }
    }
    func emailCampResWebsite() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([(campusResource?.email)!])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Email", message: "Unable to send email at this time. Please ensure that you have connected your phone to at least one email account via the Mail app.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
//    @IBAction func emailCampusResource(_ sender: UIButton) {
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            mail.mailComposeDelegate = self
//            mail.setToRecipients([(campusResource?.email)!])
//            mail.setMessageBody("", isHTML: true)
//
//            present(mail, animated: true)
//
//        } else {
//            let alert = UIAlertController(title: "Email", message: "Unable to send email at this time. Please ensure that you have connected your phone to at least one email account via the Mail app.", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//    
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // MARK: - ResourceDetailProvider
    static func newInstance() -> ResourceDetailProvider {
        return fromIB()
    }
    
    var resource: Resource
        {
        get { return campusResource }
        set
        {
            if viewIfLoaded == nil, campusResource == nil, let newCampusResource = newValue as? CampusResource
            {
                campusResource = newCampusResource
                title = campusResource.name
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
        return campusResource.imageURL
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
        let width = view.bounds.width
        let height = campusStack.height
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


extension CampusResourceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let campResInfoCell = campusResDetailTableview.dequeueReusableCell(withIdentifier: "campusResourceDetail", for: indexPath) as! CampusResourceDetailCell
        
        campResInfoCell.campResIconImage.image = iconImages[indexPath.row]
        campResInfoCell.campResIconInfo.text = campResInfo[indexPath.row]
        campResInfoCell.campResIconInfo.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        return campResInfoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        
        if indexPath.row == 0 {
            // do nothing
        } else if indexPath.row == 1 {
            callCampRes()
        }
//        else if indexPath.row == 2 {
//            emailCampResWebsite()
//        }
        else if indexPath.row == 2 {
//            getMap()
        }
    }
    
    
    
}



