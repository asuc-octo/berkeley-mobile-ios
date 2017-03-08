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

class LibraryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, ResourceDetailProvider {
    
    @IBOutlet var libraryImage: UIImageView!
    @IBOutlet var libraryDetailTableView: UITableView!
    @IBOutlet var libraryMapView: GMSMapView!
    @IBOutlet var libraryName: UILabel!
    @IBOutlet var libraryAddress: UIButton!
    
    var library:Library?
    var locationManager = CLLocationManager()
    var realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //libraryImage.sd_setImage(with: library?.imageURL!)
        libraryDetailTableView.delegate = self
        libraryDetailTableView.dataSource = self
        libraryDetailTableView.isScrollEnabled = false
        setUpMap()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "libraryTime") as! LibraryTimeCell
            
            //Converting the date to Pacific time and displaying
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")
            
            if (self.library?.weeklyClosingTimes[0] == nil) {
                cell.libraryStartEndTime.text = ""
                cell.libraryStatus.text = "Closed"
                cell.libraryStatus.textColor = UIColor.red
                return cell
            }
            
            let localOpeningTime = dateFormatter.string(from: (self.library?.weeklyOpeningTimes[0])!)
            let localClosingTime = dateFormatter.string(from: (self.library?.weeklyClosingTimes[0])!)
            
            cell.libraryStartEndTime.text = localOpeningTime + " to " + localClosingTime
            
            //Calculating whether the library is open or not
            var status = "Open"
            if (self.library?.weeklyClosingTimes[0]?.compare(NSDate() as Date) == .orderedAscending) {
                status = "Closed"
            }
            cell.libraryStatus.text = status
            if (status == "Open") {
                cell.libraryStatus.textColor = UIColor.green
            } else {
                cell.libraryStatus.textColor = UIColor.red
            }
            
            cell.height = 125
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "option") as! OptionsCell
            // For favoriting
            if (library?.favorited == true) {
                cell.favoriteButton.setImage(UIImage(named:"heart-large-filled"), for: .normal)
            } else {
                cell.favoriteButton.setImage(UIImage(named:"heart-large"), for: .normal)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
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
        
        library?.favorited = !(library?.favorited!)!
        
        //Realm adding and deleting favorite libraries
        let favLibrary = FavoriteLibrary()
        favLibrary.name = (library?.name)!
        
        if (library?.favorited == true) {
            (sender as! UIButton).setImage(UIImage(named:"heart-large-filled"), for: .normal)
        } else {
            (sender as! UIButton).setImage(UIImage(named:"heart-large"), for: .normal)
        }
        
        if (library?.favorited)! {
            try! realm.write {
                realm.add(favLibrary)
            }
        } else {
            let libraries = realm.objects(FavoriteLibrary.self)
            for lib in libraries {
                if lib.name == library?.name {
                    try! realm.write {
                        realm.delete(lib)
                    }
                }
            }
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
        
        let status = getLibraryStatus(library: library!)
        if (status == "Open") {
            marker.icon = GMSMarker.markerImage(with: .green)
        } else {
            marker.icon = GMSMarker.markerImage(with: .red)
        }
        
        marker.snippet = status
        marker.map = self.libraryMapView

    }
    
    func getLibraryStatus(library: Library) -> String {
        
        //Determining Status of library
        let todayDate = NSDate()
        
        if (library.weeklyClosingTimes[0] == nil) {
            return "Closed"
        }
        
        var status = "Open"
        if (library.weeklyClosingTimes[0]!.compare(todayDate as Date) == .orderedAscending) {
            status = "Closed"
        }
        
        return status
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
        let height = libraryDetailTableView.height + libraryMapView.height
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
