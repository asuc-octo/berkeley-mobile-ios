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
    
    @IBOutlet var campusResDetailView: UIView!
    @IBOutlet var campusResFavoriteButton: UIButton!
    @IBOutlet var campusResStartEndTime: UILabel!
    @IBOutlet var campusResMapView: GMSMapView!
    
    var campusResource:CampusResource!
    var locationManager = CLLocationManager()
    
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
    
        setUpMap()
        setUpInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpInformation() {
        self.campusResStartEndTime.text = self.campusResource.hours
        
        // For favoriting
        if (campusResource.isFavorited) {
            self.campusResFavoriteButton.setImage(#imageLiteral(resourceName: "heart-large-filled"), for: .normal)
        } else {
            self.campusResFavoriteButton.setImage(#imageLiteral(resourceName: "heart-large"), for: .normal)
        }
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
        
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = campusResource?.name
        marker.map = self.campusResMapView
    }
    
    @IBAction func callCampusResource(_ sender: UIButton) {
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
    
    @IBAction func emailCampusResource(_ sender: UIButton) {
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
        let height = campusResDetailView.height + campusResMapView.height
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
