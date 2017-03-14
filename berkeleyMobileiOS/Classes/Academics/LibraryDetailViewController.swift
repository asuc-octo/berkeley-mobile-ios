//
//  LibraryDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/13/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps

fileprivate let kLibraryCellHeight: CGFloat = 125.0

class LibraryDetailViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, ResourceDetailProvider {
    
    @IBOutlet var libraryDetailView: UIView!
    @IBOutlet var libraryFavoriteButton: UIButton!
    @IBOutlet var libraryStartEndTime: UILabel!
    @IBOutlet var libraryStatus: UILabel!
    @IBOutlet var libraryImage: UIImageView!
    @IBOutlet var libraryDetailTableView: UITableView!
    @IBOutlet var libraryMapView: GMSMapView!
    @IBOutlet var libraryName: UILabel!
    @IBOutlet var libraryAddress: UIButton!
    
    var library:Library?
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //libraryImage.sd_setImage(with: library?.imageURL!)
        setUpMap()
        setUpInformation();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpInformation() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        
        if (self.library?.weeklyClosingTimes[0] == nil) {
            self.libraryStartEndTime.text = ""
            self.libraryStatus.text = "Closed"
            self.libraryStatus.textColor = UIColor.red
            
        } else {
            let localOpeningTime = dateFormatter.string(from: (self.library?.weeklyOpeningTimes[0])!)
            let localClosingTime = dateFormatter.string(from: (self.library?.weeklyClosingTimes[0])!)
            
            self.libraryStartEndTime.text = localOpeningTime + " to " + localClosingTime
            
            //Calculating whether the library is open or not
            var status = "Open"
            if (self.library?.weeklyClosingTimes[0]?.compare(NSDate() as Date) == .orderedAscending) {
                status = "Closed"
            }
            self.libraryStatus.text = status
            if (status == "Open") {
                self.libraryStatus.textColor = UIColor.green
            } else {
                self.libraryStatus.textColor = UIColor.red
            }
        }
    
        // For favoriting
        if (library?.favorited == true) {
            self.libraryFavoriteButton.setImage(UIImage(named:"heart-large-filled"), for: .normal)
        } else {
            self.libraryFavoriteButton.setImage(UIImage(named:"heart-large"), for: .normal)
        }
        return
    }

    
    @IBAction func callLibrary(_ sender: Any) {
        let numberArray = self.library?.phoneNumber?.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        var number = ""
        for n in numberArray! {
            number += n
        }
        
        if let url = URL(string: "telprompt://\(number)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func favoriteLibrary(_ sender: Any) {
        guard let library = self.library else {
            return
        }
        library.favorited = !library.favorited
        FavoriteStore.shared.update(library)
        
        if library.favorited {
            (sender as! UIButton).setImage(UIImage(named:"heart-large-filled"), for: .normal)
        } else {
            (sender as! UIButton).setImage(UIImage(named:"heart-large"), for: .normal)
        }
        
    }
    
    @IBAction func viewLibraryWebsite(_ sender: Any) {
        
        UIApplication.shared.open(NSURL(string: "http://www.lib.berkeley.edu/libraries/main-stacks")! as URL,  options: [:], completionHandler: nil)
    }
    

    @IBAction func viewLibraryMap(_ sender: Any) {
        
        let lat = library?.latitude!
        let lon = library?.longitude!
        
        UIApplication.shared.open(NSURL(string: "https://www.google.com/maps/dir/Current+Location/" + String(describing: lat!) + "," + String(describing: lon!))! as URL,  options: [:], completionHandler: nil)

    }
    
    func setUpMap() {
        //Setting up map view
        libraryMapView.delegate = self
        libraryMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.libraryMapView.camera = camera
        self.libraryMapView.frame = self.view.frame
        self.libraryMapView.isMyLocationEnabled = true
        self.libraryMapView.delegate = self
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
            self.libraryMapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
//            print(error)
        }
        
        let lat = library?.latitude!
        let lon = library?.longitude!
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        marker.title = library?.name
        
        let status = library?.isOpen;
        if status! {
            marker.icon = GMSMarker.markerImage(with: .green)
            marker.snippet = "Open"
        } else {
            marker.icon = GMSMarker.markerImage(with: .red)
            marker.snippet = "Closed"
            
        }
        marker.map = self.libraryMapView

    }
    
    
    
    
    
    func setData(_ library: Library) {
        self.library = library
        
        self.title = library.name
        
        
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
        return library?.imageURL
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
        let height = libraryDetailView.height + libraryMapView.height
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
