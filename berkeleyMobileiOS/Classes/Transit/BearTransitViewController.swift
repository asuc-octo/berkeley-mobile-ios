//
//  BearTransitViewController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/6/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
import GoogleMaps
import GooglePlaces
import DropDown
import Alamofire
import SwiftyJSON
import Firebase
import KCFloatingActionButton
import MapKit
import ExpandingMenu
//import Crashlytics
extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.cornerRadius = 5.0
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension FABMenuController {
    override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
class BearTransitViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.width, height: 115)
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return nearestBuses.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nearestBusCell", for: indexPath) as! nearBusCollectionCell
//        let nearestB = nearestBuses[indexPath.row]
//        let toset: [UILabel] = [cell.shortestTime, cell.mediumTime, cell.smallTime]
//        let tosetmins: [UILabel] = [cell.min1, cell.min2, cell.min3]
//        let timesList = nearestB.timeLeft
//        for i in 0...2 {
////            if nearestB.busName == "No Buses Available" {
//////                toset[i].isHidden = true
//////                tosetmins[i].isHidden = true
////            } else {
//                if timesList.count > i {
//                    toset[i].text = timesList[i].components(separatedBy: ":")[0]
//                } else {
//                    toset[i].text = "--"
//                }
//
//        }
//        cell.busName.text = nearestB.busName
//        cell.busDescriptor.text = nearestB.directionTitle
//
//        return cell
//    }
    
    @IBOutlet weak var iconInfoView: UIView!
    
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        iconInfoView.isHidden = true
        menuButton.isHidden = false
    }
    
    @IBOutlet weak var distanceFromUserDisplay: UILabel!
    
    @IBOutlet weak var selectedIconDisplay: UIImageView!
    
    @IBOutlet weak var iconTitleDisplay: UILabel!
    
    @IBOutlet weak var colorDisplay: UIView!
    
    @IBOutlet weak var info1DisplayLabel: UILabel!
    
    @IBOutlet weak var info2DisplayLabel: UILabel!
    
    
    

class LocationMarkersData {
    var category = ""
    var lat = ""
    var lon = ""
    var building = ""
    var floor = ""
    var imageUrl = ""
    var icon = UIImage()
    init() {
    }
    
    func setCategory(text: String) {
        category = text
    }
    
    func setLatitude(text: String) {
        lat = text
    }
    
    func setLongitude(text: String) {
        lon = text
    }
    
    func setBuilding(text: String) {
        building = text
    }
    
    func setFloor(text: String) {
        floor = text
    }
    
    func setImage(text: String) {
        imageUrl = text
    }
    
    
}


// class BearTransitViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
//     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//         return CGSize(width: self.view.width, height: 115)
//     }
//     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//         return nearestBuses.count
//     }
    
// //    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
// //        //super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
// //        //super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
// //
// //        super.init(rootViewController: self)
// //    }
    
// //    required init?(coder aDecoder: NSCoder) {
// //        fatalError("init(coder:) has not been implemented")
// //    }
    
//     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nearestBusCell", for: indexPath) as! nearBusCollectionCell
//         let nearestB = nearestBuses[indexPath.row]
//         let toset: [UILabel] = [cell.shortestTime, cell.mediumTime, cell.smallTime]
//         let tosetmins: [UILabel] = [cell.min1, cell.min2, cell.min3]
//         let timesList = nearestB.timeLeft
//         for i in 0...2 {
//             //            if nearestB.busName == "No Buses Available" {
//             ////                toset[i].isHidden = true
//             ////                tosetmins[i].isHidden = true
//             //            } else {
//             if timesList.count > i {
//                 toset[i].text = timesList[i].components(separatedBy: ":")[0]
//             } else {
//                 toset[i].text = "--"
//             }
            
//         }
//         cell.busName.text = nearestB.busName
//         cell.busDescriptor.text = nearestB.directionTitle
        
//         return cell
//     }
// >>>>>>> develop
    
    //Sets up initial tab look for this class
    @IBOutlet var stopTimeButton: UIButton!
    var dropDown: DropDown?
    var endDropDown: DropDown?
    var routes: [Route] = []
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    //    @IBOutlet var busesNotAvailable: UILabel!
    @IBOutlet weak var routesTable: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var destView: UIView!
    @IBOutlet weak var block1: UIView!
    @IBOutlet weak var block2: UIView!
    var markers:[GMSMarker] = []
    @IBOutlet weak var nearestBusCollection: UICollectionView!
    var darkBlue = UIColor.init(red: 2/255, green: 46/255, blue: 129/255, alpha: 1)
    var lightBlue = UIColor.init(red: 38/255, green: 133/255, blue: 245/255, alpha: 1)
    var serverToLocalFormatter = DateFormatter.init()
    var timeFormatter = DateFormatter.init()
    var pressed: Bool = true
    let defaultCoord: [Double] = [37.871853, -122.258423]
    var nearestBuses: [nearestBus] = []
    //    @IBOutlet var nearestBusesTable: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    var startLat: [Double] = [37.871853, -122.258423]
    var stopLat: [Double] = [37.871853, -122.258423]
    var selectedIndexPath = 0
    var polylines:[GMSPolyline] = []
    var whitedIcons:[GMSMarker] = []
    var liveBusMarkers: [String: GMSMarker] = [:]
    
    // FabController Instances Begin
//    fileprivate let fabMenuSize = CGSize(width: 56, height: 56)
//    fileprivate let bottomInset: CGFloat = 24
//    fileprivate let rightInset: CGFloat = 24
//
//    fileprivate var fabButton: FABButton!
//    fileprivate var notesFABMenuItem: FABMenuItem!
//    fileprivate var remindersFABMenuItem: FABMenuItem!
    // FabController Instances End
    
    
    @IBOutlet weak var noRoutesFound: UIView!
    @IBOutlet weak var alertImage: UIImageView!
    @IBAction func toggleStops(_ sender: Any) {
        self.routesTable.isHidden = true
        //        self.nearestBusesTable.isHidden = true
        if pressed {
            turnStopsOFF()
        } else {
            zoomToCurrentLocation()
            turnStopsON()
        }
    }
    func turnStopsON() {
        for p in polylines{
            p.map = nil
        }
        self.mapView.clear()
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        //        backgroundQueue.async {
        self.populateMapWithStops()
        //        }
        pressed = true
        stopTimeButton.applyGradient(colours: [darkBlue, lightBlue])
        stopTimeButton.setTitleColor(UIColor.white, for: .normal)
        
        //        stopTimeButton.setTitleColor(UIColor.init(red: 0/255, green: 85/255, blue: 129/255, alpha: 1), for: .normal)
        //        stopTimeButton.borderColor = UIColor.init(red: 0/255, green: 85/255, blue: 129/255, alpha: 1)
    }
    
//    open override func prepare() {
//        super.prepare()
//        view.backgroundColor = .white
//
//        prepareFABButton()
//        prepareNotesFABMenuItem()
//        prepareRemindersFABMenuItem()
//        prepareFABMenu()
//    }
    
    
    func turnStopsOFF() {
        self.mapView.clear()
        pressed = false
        self.nearestBusCollection.isHidden = true
        //        stopTimeButton.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        //        stopTimeButton.setTitleColor(darkBlue, for: .normal)
        
    }
    func zoomToCurrentLocation() {
        if let coord = manager.location?.coordinate {
            self.mapView.animate(toLocation: CLLocationCoordinate2D.init(latitude: coord.latitude, longitude: coord.longitude))
            self.mapView.animate(toZoom: 16.5)
        }
        
    }
    func setupMap() {
        //Setting up map view
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        //        mapView.settings.myLocationButton = true
    }
    override func viewDidAppear(_ animated: Bool) {
        if (startField.text == "Current Location") {
            if let coord = manager.location?.coordinate {
                startLat = [coord.latitude, coord.longitude]
            }
        }
        //        Crashlytics.sharedInstance().crash()
        Analytics.logEvent("opened_transit_screen", parameters: nil)
        
        //        zoomToCurrentLocation()
        
    }
    
    func setupStartDestFields() {
        //        self.makeMaterialShadow(withView: startField)
        //        self.makeMaterialShadow(withView: destinationField)
        self.makeMaterialShadow(withView: destView)
        self.makeMaterialShadow(withView: stopTimeButton)
        self.makeMaterialShadow(withView: goButton)
        startField.delegate = self
        destinationField.delegate = self
        configureDropDown()
    }
    func zoomToLoc() {
        if let coord = manager.location?.coordinate {
            startLat = [coord.latitude, coord.longitude]
        }
        zoomToCurrentLocation()
    }
    func setupLocationManager() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    func setupTimeFormatters() {
        serverToLocalFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        serverToLocalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        timeFormatter.dateFormat = "h:mm a"
        serverToLocalFormatter.locale = Locale.init(identifier: "en_US_POSIX")
    }
    
    var dict: [String : [[String : Any]]] = [String : [[String : Any]]]()
    var microwaVeCoordinates = [LocationMarkersData]()
    var waterFountainCoordinates = [LocationMarkersData]()
    var napPodsCoordinates = [LocationMarkersData]()
//
//    [
//    "Microwave": [
//    [
//    "category": "microwave",
//    "lat": "37.871074",
//    "lon": "-122.26137",
//    "description1": "mlk",
//    "description2": "floor2",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ], [
//    "category": "microwave",
//    "lat": "37.871074",
//    "lon": "-122.26137",
//    "description1": "li ka shing",
//    "description2": "floor2",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ],
//    [
//    "category": "microwave",
//    "lat": "37.871074",
//    "lon": "-122.261267",
//    "description1": "li ka shing",
//    "description2": "floor2",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ]
//    ],
//    "Water Fountain": [
//    [
//    "category": "Water Fountain",
//    "lat": "37.871024",
//    "lon": "-122.259524",
//    "description1": "Sather Gate",
//    "description2": "Under the Bridge",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ],
//    [
//    "category": "Water Fountain",
//    "lat": "37.871024",
//    "lon": "-122.989524",
//    "description1": "Unit 3",
//    "description2": "Under the Bridge",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ],
//    [
//    "category": "Water Fountain",
//    "lat": "37.991024",
//    "lon": "-122.989524",
//    "description1": "Clark Kerr",
//    "description2": "Under the Bridge",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ]
//    ],
//    "Nap Pods": [
//    [
//    "category": "Nap Pod",
//    "lat": "37.971024",
//    "lon": "-122.259524",
//    "description1": "North Gate",
//    "description2": "Under the Bridge",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ],
//    [
//    "category": "Nap Pod",
//    "lat": "37.9981024",
//    "lon": "-122.259524",
//    "description1": "South Gate",
//    "description2": "Under the Bridge",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ],
//    [
//    "category": "Nap Pod",
//    "lat": "37.9981024",
//    "lon": "-122.309524",
//    "description1": "GBC",
//    "description2": "Under the Bridge",
//    "image_link": "https://upload.wikimedia.org//wikipedia//commons//thumb//8//85//Consumer_Reports_-_Kenmore_microwave_oven.tif//lossy-page1-1200px-Consumer_Reports_-_Kenmore_microwave_oven.tif.jpg"
//    ]
//    ]
//    ]
    
    
    
    func getCoordinates() {
        
        let apiToContact = "http://asuc-mobile-dev.herokuapp.com/api/map"
        // This code will call the iTunes top 25 movies endpoint listed above
        Alamofire.request(apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    //let json = JSON(value)
                    
                    self.dict = value as! [String : [[String : Any]]]
                    
                    //WaterFountain Coordinates
                    let waterData = self.dict["Water Fountain"]!
                    for loc in waterData {
                        let finalData = loc
                        let location = LocationMarkersData()
                        if let c = finalData["description2"]! as? String {
                            location.setImage(text: c)
                        }
                        location.setCategory(text: finalData["category"]! as! String)
                        location.setLatitude(text: String(finalData["lat"]! as! Double))
                        location.setLongitude(text: String(finalData["lon"]! as! Double))
                        location.setBuilding(text: finalData["description1"]! as! String)
                        if let b = finalData["image_link"]! as? String {
                            location.setImage(text: b)
                        }
                        location.icon = #imageLiteral(resourceName: "water_fountains")
                        self.waterFountainCoordinates.append(location)
                    }
                    //Microwave Coordinates
                    let microData = self.dict["Microwave"]!
                    for loc in microData {
                        let finalData = loc
                        let location = LocationMarkersData()
                        if let c = finalData["description2"]! as? String {
                            location.setImage(text: c)
                        }
                        location.setCategory(text: finalData["category"]! as! String)
                        location.setLatitude(text: String(finalData["lat"]! as! Double))
                        location.setLongitude(text: String(finalData["lon"]! as! Double))
                        location.setBuilding(text: finalData["description1"]! as! String)
                        if let b = finalData["image_link"]! as? String {
                            location.setImage(text: b)
                        }
                        location.icon = #imageLiteral(resourceName: "microwaves")
                        self.microwaVeCoordinates.append(location)
                    }
                    
                    if let napData = self.self.dict["Nap Pod"] {
                        for loc in napData {
                            let finalData = loc
                            let location = LocationMarkersData()
                            if let c = finalData["description2"]! as? String {
                                location.setImage(text: c)
                            }
                            location.setCategory(text: finalData["category"]! as! String)
                            location.setLatitude(text: String(finalData["lat"]! as! Double))
                            location.setLongitude(text: String(finalData["lon"]! as! Double))
                            location.setBuilding(text: finalData["description1"]! as! String)
                            if let b = finalData["image_link"]! as? String {
                                location.setImage(text: b)
                            }
                            location.icon = #imageLiteral(resourceName: "nap_pods")
                            self.napPodsCoordinates.append(location)
                        }
                    }
                    
                    
                    
                }
            case .failure(let error):
                let alert = UIAlertController.init(title: "Couldn't load icons", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }

        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCoordinates()
        
        
        iconInfoView.isHidden = true
        iconInfoView.clipsToBounds = true
        mapView.addSubview(iconInfoView)
        
        
        self.mapView.delegate = self
        //        busesNotAvailable.isHidden = true
        self.routesTable.isHidden = true
        //        nearestBusesTable.isHidden = true
        nearestBusCollection.isHidden = true
        setupMap()
        //        populateMapWithStops()
        setupStartDestFields()
        makeMaterialShadow(withView: routesTable)
        setupLocationManager()
        setupTimeFormatters()
        self.goButton.applyGradient(colours: [darkBlue, lightBlue])
        self.stopTimeButton.applyGradient(colours: [darkBlue, lightBlue])
        self.destView.cornerRadius = 5.0
        self.stopTimeButton.layer.cornerRadius = 5.0
        self.goButton.layer.cornerRadius = 5.0
        block1.layer.cornerRadius = 0.5*block1.frame.width
        block2.layer.cornerRadius = 0.5*block2.frame.width
        //        stopTimeButton.titleLabel?.textColor = UIColor.white
        stopTimeButton.setTitleColor(UIColor.white, for: .normal)
        stopTimeButton.isHidden = true
//        nearestBusCollection.delegate = self
//        nearestBusCollection.dataSource = self
        goButton.setTitle("Go", for: .normal)
        zoomToLoc()
        alertImage.image =  #imageLiteral(resourceName: "alert").withRenderingMode(.alwaysTemplate).tint(with: .white)
        //        alertImage.image?.tint(with: .white)
        noRoutesFound.isHidden = true
        makeMaterialShadow(withView: noRoutesFound)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLiveBuses), userInfo: nil, repeats: true)
        
        
        //Round Menu Setup
        //let fab = KCFloatingActionButton()
        
        //
        menuButton.center = CGPoint(x: self.view.bounds.width - 44.0, y: self.view.bounds.height - 100.0)
        menuButton.menuItemMargin = 10
        menuButton.allowSounds = false
        view.addSubview(menuButton)
        
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "", image: #imageLiteral(resourceName: "water_fountains"), highlightedImage: #imageLiteral(resourceName: "water_fountains"), backgroundImage: #imageLiteral(resourceName: "water_fountains"), backgroundHighlightedImage: #imageLiteral(resourceName: "water_fountains")) { () -> Void in
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": "Waterfountain"])
            self.markers.append(contentsOf: self.chosenMarkers)
            self.chosenMarkers.removeAll()
            self.getCoordinates()
            for coordinate in self.waterFountainCoordinates {
                let latitude =  Double(coordinate.lat) //{
                let longitude =  Double(coordinate.lon) //{
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                let marker = GMSMarker(position: location.coordinate)
                //annotation.image = "greekicon"
                //let centerCoordinate =
                //marker. = centerCoordinate
                marker.map = self.mapView
                marker.title = coordinate.building
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "water_fountains"), scaledToSize: CGSize(width: 50.0, height: 50.0))
                //marker.iconView?.sizeThatFits(CGSize(width: 5.0, height: 5.0))
                self.chosenMarkers.append(marker)
            }
            self.selectedIcons = self.waterFountainCoordinates
//            self.markers.append(contentsOf: self.chosenMarkers)
        }
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "", image: #imageLiteral(resourceName: "microwaves"), highlightedImage: #imageLiteral(resourceName: "microwaves"), backgroundImage: #imageLiteral(resourceName: "microwaves"), backgroundHighlightedImage: #imageLiteral(resourceName: "microwaves")) { () -> Void in
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": "Microwave"])

            self.markers.append(contentsOf: self.chosenMarkers)
            self.chosenMarkers.removeAll()
            self.getCoordinates()
            for coordinate in self.microwaVeCoordinates {
                let latitude =  Double(coordinate.lat) //{
                let longitude =  Double(coordinate.lon) //{
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                let marker = GMSMarker(position: location.coordinate)
                marker.map = self.mapView
                marker.title = coordinate.building
                
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "microwaves"), scaledToSize: CGSize(width: 50.0, height: 50.0))
                //ma0rker.iconView?.sizeThatFits(CGSize(width: 5.0, height: 5.0))
                //marker.iconView.s
                self.chosenMarkers.append(marker)
            }
            self.selectedIcons = self.microwaVeCoordinates
//            self.markers.append(contentsOf: self.chosenMarkers)
        }
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: "", image: #imageLiteral(resourceName: "nap_pods"), highlightedImage: #imageLiteral(resourceName: "nap_pods"), backgroundImage: #imageLiteral(resourceName: "nap_pods"), backgroundHighlightedImage: #imageLiteral(resourceName: "nap_pods")) { () -> Void in
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": "Nappod"])

            self.markers.append(contentsOf: self.chosenMarkers)
            self.chosenMarkers.removeAll()
            self.getCoordinates()
            for coordinate in self.napPodsCoordinates {
                let latitude =  Double(coordinate.lat) //{
                let longitude =  Double(coordinate.lon) //{
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                let marker = GMSMarker(position: location.coordinate)
                marker.map = self.mapView
                marker.title = coordinate.building
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "nap_pods"), scaledToSize: CGSize(width: 50.0, height: 50.0))
                //ma0rker.iconView?.sizeThatFits(CGSize(width: 5.0, height: 5.0))
                //marker.iconView.s
                self.chosenMarkers.append(marker)
//                self.markers.append(contentsOf: self.chosenMarkers)
            }
            self.selectedIcons = self.napPodsCoordinates
//            self.markers.append(contentsOf: self.chosenMarkers)
        }
        
        menuButton.addMenuItems([item1, item2, item3])
       // self.view.addSubview(menuButton)
//        fab.addItem(icon: UIImage(named: "water_fountains"), handler: { item in
//
//
//               // }
//            fab.close()
//        })
//        fab.addItem(icon: UIImage(named: "microwaves"), handler: { item in
//
//            fab.close()
//        })
//        fab.addItem(icon: UIImage(named: "nap_pods"), handler: { item in
//
//            fab.close()
//        })
//        self.view.addSubview(fab)
    }
    
    let menuButtonSize: CGSize = CGSize(width: 60.0, height: 60.0)
    //let smallerMenu: CGSize = CGSize(width: 5.0, height: 5.0)
    let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 60.0, height: 60.0)), centerImage:  #imageLiteral(resourceName: "white_eye"), centerHighlightedImage: #imageLiteral(resourceName: "white_eye"))
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
   var selectedIcons = [LocationMarkersData]()
    var chosenMarkers = [GMSMarker]()
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        var skip = false
        for mak in microwaVeCoordinates {
            if mak.building == marker.title {
                
                let theHeight = self.view.frame.size.height //grabs the height of your view
                
                var nextBar = UIView()
                
                nextBar.backgroundColor = UIColor(red: 7/255, green: 152/255, blue: 253/255, alpha: 0.5)
                
                nextBar.frame = CGRect(x: 0, y: theHeight - 50 , width: self.view.frame.width, height: 50)
                
                self.view.addSubview(nextBar)
                
                skip = true
                break
            }
        }
        if !skip {
            
            
        }
    }
    
    
    func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        startField.endEditing(true)
        destinationField.endEditing(true)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideKeyBoard()
    }
    
    func displayGoButtonOnCondition() {
        if (startLat != defaultCoord && stopLat != defaultCoord) {
            goButton.isHidden = false
            //            stopTimeButton.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            //            stopTimeButton.titleLabel?.textColor = darkBlue
            
        }
    }
    
    func configureDropDown() {
        let dropper = DropDown()
        dropper.anchorView = self.destView
        dropper.dismissMode = .onTap
        dropper.bottomOffset = CGPoint(x: 0, y:dropper.anchorView!.plainView.bounds.height + 8)
        dropper.dataSource = ["Start Typing!"]
        dropper.selectionAction = { [unowned self] (index: Int, item: String) in
            self.startField.text = item
            self.startField.resignFirstResponder()
            self.startLat = self.getLatLngForZip(address: item)
            self.displayGoButtonOnCondition()
        }
        dropper.backgroundColor = UIColor.white
        //        dropper.width = dropper.anchorView!.plainView.frame.width
        self.dropDown = dropper
        
        let enddropper = DropDown()
        enddropper.anchorView = self.destView
        enddropper.dismissMode = .onTap
        enddropper.bottomOffset = CGPoint(x: 0, y:dropper.anchorView!.plainView.bounds.height + 8)
        enddropper.dataSource = ["Start Typing!"]
        enddropper.selectionAction = { [unowned self] (index: Int, item: String) in
            self.destinationField.text = item
            self.destinationField.resignFirstResponder()
            self.stopLat = self.getLatLngForZip(address: item)
            self.displayGoButtonOnCondition()
        }
        //        enddropper.width = dropper.anchorView!.plainView.width
        enddropper.backgroundColor = UIColor.white
        self.endDropDown = enddropper
    }
    
    @IBAction func toggleStartStop(_ sender: Any) {
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {() -> Void in
            self.toggleHidden(someView: self.startField)
            self.toggleHidden(someView: self.destinationField)
            
        }, completion: { _ in
            self.configureDropDown()
        })
    }
    
    @IBAction func searchRoutes(_ sender: Any) {
        
        // check if location fields are empty
        if (self.destinationField.text == "") {
            let alertController = UIAlertController(title: "Destination Missing", message: "Please enter a valid destination.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "Ok", style: .default) { action in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            return
        }
        if (self.startField.text == "") {
            let alertController = UIAlertController(title: "No Starting Point", message: "Please enter a valid starting point.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "Ok", style: .default) { action in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            return
        }
        
        //Get Array In Order Of Soonest of Bus Name, Start Time, End Time Bus Name, Full Routes with latitude and longitudes
        Analytics.logEvent("clicked_go_button", parameters: ["Route" : "Yes"])
        if self.goButton.titleLabel?.text == "Go" {
            self.routesTable.isHidden = true
            for p in polylines{
                p.map = nil
            }
            self.nearestBusCollection.isHidden = true
            //            self.busesNotAvailable.isHidden = true
            turnStopsOFF()
            polylines = []
            self.goButton.setTitle("Loading", for: .normal)
            fullRouteDataSource.fetchBuses({ (routesArray: [Route]!) in
                self.routes = routesArray!
                if (self.routes.count == 0) {
                    //                    self.busesNotAvailable.isHidden = false
                    self.noRoutesFound.isHidden = false
                } else {
                    self.routesTable.reloadData()
                    var averageLatLon = [0.0, 0.0]
                    for stopIndex in 0...(self.routes[0].stops.count - 2) {
                        let lon1 = self.routes[0].stops[stopIndex].longitude
                        let lat1 = self.routes[0].stops[stopIndex].latitude
                        averageLatLon[0] += lat1
                        averageLatLon[1] += lon1
                        self.drawPath(self.routes[0].stops[stopIndex], self.routes[0].stops[stopIndex + 1])
                        if stopIndex != 0 {
                            let marker4 = GMSMarker()
                            marker4.icon =  #imageLiteral(resourceName: "bluecircle").resize(toWidth: 18)
                            let loc = CLLocationCoordinate2D.init(latitude: lat1, longitude: lon1)
                            marker4.position = loc
                            marker4.snippet = self.routes[0].stops[stopIndex].name
                            marker4.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
                            marker4.map = self.mapView
                        }
                        
                    }
                    let lon1 = self.routes[0].stops[self.routes[0].stops.count - 1].longitude
                    let lat1 = self.routes[0].stops[self.routes[0].stops.count - 1].latitude
                    //                    let marker4 = GMSMarker()
                    //                    marker4.icon = #imageLiteral(resourceName: "bluecircle")
                    //                    let loc2 = CLLocationCoordinate2D.init(latitude: lat1, longitude: lon1)
                    //                    marker4.position = loc2
                    //                    marker4.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
                    //                    marker4.map = self.mapView
                    averageLatLon[0] += lat1
                    averageLatLon[1] += lon1
                    averageLatLon[0] /= Double(self.routes[0].stops.count)
                    averageLatLon[1] /= Double(self.routes[0].stops.count)
                    let loc: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: averageLatLon[0], longitude: averageLatLon[1])
                    self.mapView.animate(toLocation: loc)
                    self.mapView.animate(toZoom: 14)
                    
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: self.routes[0].stops[0].latitude, longitude: self.routes[0].stops[0].longitude)
                    marker.icon =  #imageLiteral(resourceName: "blueStop").withRenderingMode(.alwaysTemplate).tint(with: Color.green.accent3)
                    marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5);
                    marker.map = self.mapView
                    let smarker = GMSMarker()
                    smarker.position = CLLocationCoordinate2D(latitude: self.routes[0].stops[self.routes[0].stops.count - 1].latitude, longitude: self.routes[0].stops[self.routes[0].stops.count - 1].longitude)
                    smarker.map = self.mapView
                    smarker.icon = #imageLiteral(resourceName: "blueStop").withRenderingMode(.alwaysTemplate).tint(with: Color.red.accent3)
//                    self.routesTable.isHidden = false
                    
                    self.performSegue(withIdentifier: "routeResults", sender: self)
                }
                self.goButton.setTitle("Done", for: .normal)
            }, startLat: String(self.startLat[0]), startLon: String(self.startLat[1]), destLat: String(self.stopLat[0]), destLon: String(self.stopLat[1]))
            
            self.goButton.layer.sublayers?.removeFirst()
            goButton.setTitleColor(darkBlue, for: .normal)
        } else {
            self.routesTable.isHidden = true
            for p in polylines{
                p.map = nil
            }
            turnStopsOFF()
            self.noRoutesFound.isHidden = true
            self.nearestBusCollection.isHidden = true
            //            self.busesNotAvailable.isHidden = true
            //            goButton.isHidden = true
            goButton.setTitle("Go", for: .normal)
            self.goButton.applyGradient(colours: [darkBlue, lightBlue])
            goButton.setTitleColor(UIColor.white, for: .normal)
        }
        
    }
    

    func drawPath(_ startStop: routeStop, _ destStop: routeStop)
    {
        //        var averageLatLon = [0.0, 0.0]
        //        var count = 0
        let origin = "\(startStop.latitude),\(startStop.longitude)"
        let destination = "\(destStop.latitude),\(destStop.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyBC8l95akDNvy_xZqa4j3XJCuATi2wFP_g"
        if (startStop.id == 15382 && destStop.id == 15383) {
            var pat = GMSMutablePath.init()
            pat.addLatitude(startStop.latitude, longitude: startStop.longitude)
            pat.addLatitude(destStop.latitude, longitude: destStop.longitude)
            
            let polyline = GMSPolyline.init(path: pat)
            polyline.strokeWidth = 6
            polyline.strokeColor = self.lightBlue
            polyline.map = self.mapView
            self.polylines.append(polyline)
        }
        else {
            Alamofire.request(url).responseJSON { response in
                //            var lastCoord = [0.0,0.0]
                let json = JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    //                for i in 0...((path?.count())! - 1) {
                    //                    lastCoord = [(path?.coordinate(at: i).latitude)!,(path?.coordinate(at: i).longitude)!]
                    //                    averageLatLon[0] += lastCoord[0]
                    //                    averageLatLon[1] += lastCoord[1]
                    //                    count += 1
                    //                }
                    polyline.strokeWidth = 6
                    polyline.strokeColor = self.lightBlue
                    polyline.map = self.mapView
                    self.polylines.append(polyline)
                }
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let dest = segue.destination as! RouteViewController
//        dest.selectedRoute = self.routes[selectedIndexPath]
        let dest = segue.destination as! RouteResultViewController
        dest.routes = self.routes
        dest.start = startField.text
        dest.end = destinationField.text
        Analytics.logEvent("clicked_on_route", parameters: nil)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.goButton.isHidden = false
        //Replacement String is last character typed
        var placeString = textField.text!
        if (string) == "" {
            placeString = placeString.substring(to: placeString.index(before: placeString.endIndex))
        } else {
            placeString += string
        }
        if textField == self.startField {
            self.dropDown!.show()
            placeAutocomplete(placeString, self.dropDown!)
        } else {
            self.endDropDown!.show()
            placeAutocomplete(placeString, self.endDropDown!)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.startField {
            self.dropDown!.hide()
        } else {
            self.endDropDown!.hide()
        }    }
    func populateMapWithStops() {
        var allStops: Dictionary<String, Dictionary<String, Any>> = ConvenienceMethods.getAllStops()
        for key in allStops.keys {
            var currentStop:Dictionary<String, Any> = allStops[key]!
            let latitude = currentStop["lat"]
            let longitude = currentStop["lon"]
            let title = currentStop["title"]
            let code = currentStop["code"]
            let marker = GMSMarker()
            
            marker.position = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            marker.title = title as? String
            marker.snippet = code as? String
            marker.icon =  #imageLiteral(resourceName: "blueStop")
            marker.isFlat = true
            marker.map = self.mapView
        }
    }
    func toggleHidden(someView:UIView!) {
        someView.isHidden = !(someView.isHidden)
    }
    func placeAutocomplete(_ autoString: String, _ dropDown: DropDown) {
        let filter = GMSAutocompleteFilter()
        let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(37.902479, -122.313240), coordinate: CLLocationCoordinate2DMake(37.851532, -122.232216))
        filter.type = .noFilter
        filter.country = "USA"
        let client = GMSPlacesClient()
        var autoResults: [String] = ["Current Location"]
        client.autocompleteQuery(autoString, bounds: bounds, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                for result in results {
                    autoResults.append(result.attributedFullText.string)
                }
                dropDown.dataSource = autoResults
                dropDown.width = dropDown.anchorView?.plainView.width
            }
        })
    }
    
    func updateLiveBuses() {
        livebusDataSource.fetchBuses({ (_ buses: [livebus]?) in
            if (buses == nil || buses?.count == 0)
            {
                
            } else {
                //                self.mapView.clear()
                for m in self.markers {
                    m.map = nil
                }
                self.markers.removeAll()
                
//                for m in self.chosenMarkers {
//                    m.map = self.mapView
//                }
//                self.markers = []
//                self.markers.append(contentsOf: self.chosenMarkers)
                var new_buses: [String: GMSMarker] = [:]
                for bus in buses! {
                    if bus.lineName == "" {
                        continue
                    }
                    if self.liveBusMarkers.keys.contains(bus.id) {
                        self.liveBusMarkers[bus.id]!.position = CLLocationCoordinate2D(latitude: bus.latitude , longitude: bus.longitude as! CLLocationDegrees)
                        new_buses[bus.id] = self.liveBusMarkers[bus.id]!
                    } else {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: bus.latitude , longitude: bus.longitude as! CLLocationDegrees)
                        marker.title = bus.lineName
                        marker.icon =  #imageLiteral(resourceName: "bus-icon-blue")
                        marker.isFlat = true
                        marker.map = self.mapView
                        new_buses[bus.id] = marker
//                        self.markers.append(marker)
                    }
                }
                for (key, value) in self.liveBusMarkers {
                    if !new_buses.keys.contains(key) {
                        value.map = nil
                    }
                }
                self.liveBusMarkers = new_buses
            }
            
        })
    }
    
    func makeMaterialShadow(withView tf: UIView!) {
        tf.layer.masksToBounds = false
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowColor = Color.gray.cgColor
        tf.layer.shadowOffset = CGSize(width: 1, height: 1)
        tf.layer.shadowOpacity = 1
    }
    
    
    func getSelectedMarker(name: String) -> LocationMarkersData? {
        for marker in selectedIcons {
            if marker.building == name {
                return marker
            }
        }
        return nil
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //        marker.icon = #imageLiteral(resourceName: "whiteStop")
        //        for marker in whitedIcons {
        //            marker.icon = #imageLiteral(resourceName: "blueStop")
        //        }
        //        whitedIcons = []
        //        whitedIcons.append(marker)
        
        menuButton.isHidden = true
        iconInfoView.isHidden = false
        let selected = getSelectedMarker(name: marker.title!)
        var title = ""
        var color = UIColor()
        if selected?.icon == #imageLiteral(resourceName: "water_fountains"){
            title = "Bottle Filling Station"
            color = UIColor.init(hex: "2EB8CF")
        } else if selected?.icon == #imageLiteral(resourceName: "microwaves") {
            title = "Microwave Station"
            color = UIColor.init(hex: "FF702C")
        } else if selected?.icon == #imageLiteral(resourceName: "nap_pods") {
            title = "Nap Pod"
            color = UIColor.init(hex: "FF2BA3")
        }
        
        self.selectedIconDisplay.image = selected?.icon
        self.iconTitleDisplay.text = title
        self.iconTitleDisplay.textColor = color
        self.colorDisplay.backgroundColor = color
        self.info1DisplayLabel.text = selected?.building
        self.info2DisplayLabel.text = selected?.floor
        
        return false
        if let s = marker.snippet {
            self.routesTable.isHidden = true
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            //            self.nearestBusesTable.backgroundView = activityIndicatorView
            self.activityIndicatorView = activityIndicatorView
            self.activityIndicatorView.startAnimating()
            nearestStopsDataSource.fetchBuses({ (_ buses: [nearestBus]?) in
                if (buses == nil || buses?.count == 0)
                {
//                    self.nearestBusCollection.isHidden = false
                    var nb = nearestBus.init(directionTitle: "--", busName: "No Buses Available", timeLeft: "--")
                    self.nearestBuses = [nb]
                    self.nearestBusCollection.reloadData()
                    //                    self.busesNotAvailable.isHidden = false
                    //                    self.busesNotAvailable.text = "No buses servicing this stop in the near future"
                    
                } else {
//                    self.nearestBusCollection.isHidden = false
                    self.nearestBuses = buses!
                    self.nearestBusCollection.reloadData()
                    //                    self.nearestBusesTable.reloadData()
                    //                    self.activityIndicatorView.stopAnimating()
                    //                    self.nearestBusesTable.isHidden = false
                }
                
            }, stopCode:s)
        } else {
            
        }
        return false
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView.tag == 0 {
//            return self.routes.count
//        } else {
//            return self.nearestBuses.count
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 130
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView.tag == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! routeCell
//            let route: Route = routes[indexPath.row]
//            let Routecount = route.stops.count
//            cell.start.text = route.stops[0].name
//
//            if let secondBus = route.secondBusName {
//                cell.lineName.text = route.busName + " & " + secondBus
//                cell.end.text = route.secondRouteStops?.last?.name
//            } else {
//                cell.lineName.text = route.busName
//                cell.end.text = route.stops[Routecount - 1].name
//            }
//
//            let currentDate = serverToLocalFormatter.date(from: route.startTime)
//            let endDate = serverToLocalFormatter.date(from: route.endTime)
//            let timeElapsed = endDate?.timeIntervalSince(currentDate!)
//            var minutes = timeElapsed!/60
//
//            cell.duration.text = Int(minutes.rounded()).description + " mins"
//            cell.timeTravel.text = timeFormatter.string(from: currentDate!)
//            //        cell.detailTextLabel!.text = currentBus.directionTitle
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NearestBusesTableViewCell") as! NearestBusesTableViewCell
//            let nearestB = nearestBuses[indexPath.row]
//            cell.busName.text = nearestB.busName
//            cell.busLabel.text = nearestB.directionTitle
//            cell.nearestBus = nearestB
//            cell.timesCollection.delegate = cell
//            cell.timesCollection.dataSource = cell
//            cell.timesCollection.reloadData()
//            return cell
//        }
//
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if tableView.tag == 0 {
//            selectedIndexPath = indexPath.row
//            performSegue(withIdentifier: "routeDetails", sender: self)
//        }
//
//    }
// =======
//     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//         if tableView.tag == 0 {
//             return self.routes.count
//         } else {
//             return self.nearestBuses.count
//         }
//     }
//     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//         return 130
//     }
//     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         if tableView.tag == 0 {
//             let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! routeCell
//             let route: Route = routes[indexPath.row]
//             let Routecount = route.stops.count
//             cell.start.text = route.stops[0].name
            
//             if let secondBus = route.secondBusName {
//                 cell.lineName.text = route.busName + " & " + secondBus
//                 cell.end.text = route.secondRouteStops?.last?.name
//             } else {
//                 cell.lineName.text = route.busName
//                 cell.end.text = route.stops[Routecount - 1].name
//             }
            
//             let currentDate = serverToLocalFormatter.date(from: route.startTime)
//             let endDate = serverToLocalFormatter.date(from: route.endTime)
//             let timeElapsed = endDate?.timeIntervalSince(currentDate!)
//             var minutes = timeElapsed!/60
            
//             cell.duration.text = Int(minutes.rounded()).description + " mins"
//             cell.timeTravel.text = timeFormatter.string(from: currentDate!)
//             //        cell.detailTextLabel!.text = currentBus.directionTitle
//             return cell
//         } else {
//             let cell = tableView.dequeueReusableCell(withIdentifier: "NearestBusesTableViewCell") as! NearestBusesTableViewCell
//             let nearestB = nearestBuses[indexPath.row]
//             cell.busName.text = nearestB.busName
//             cell.busLabel.text = nearestB.directionTitle
//             cell.nearestBus = nearestB
//             cell.timesCollection.delegate = cell
//             cell.timesCollection.dataSource = cell
//             cell.timesCollection.reloadData()
//             return cell
//         }
        
//     }
//     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         if tableView.tag == 0 {
//             selectedIndexPath = indexPath.row
//             performSegue(withIdentifier: "routeDetails", sender: self)
//         }
        
//     }
// >>>>>>> develop
    func getLatLngForZip(address: String) -> [Double] {
        if address == "Current Location" {
            return [(manager.location?.coordinate.latitude)!, (manager.location?.coordinate.longitude)!]
        } else {
            let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
            let apikey = "AIzaSyAZaivE84tZtu9i-RS8ZLQtF3PQpCsJkTk"
            let cleanAddress = address.replacingOccurrences(of: " ", with: "")
            let urlstring = "\(baseUrl)address=\(cleanAddress)&key=\(apikey)"
            let url = URL(string: urlstring)
            let data = NSData(contentsOf: url! as URL)
            let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if let geometry = (result[0] as? NSDictionary)?["geometry"] as? NSDictionary {
                    if let location = geometry["location"] as? NSDictionary {
                        let latitude = location["lat"] as! Float
                        let longitude = location["lng"] as! Float
                        return [Double(latitude), Double(longitude)]
                    }
                }
            }
            return [0.0000, 0.0000]
        }
        
    }
}


extension KCFloatingActionButton {
    func setImage(image: UIImage) {
//        buttonImageView.removeFromSuperview()
//        buttonImageView = UIImageView(image: buttonImage)
//        buttonImageView.tintColor = plusColor
//        buttonImageView.frame = CGRect(
//            x: circleLayer.frame.origin.x + (size / 2 - buttonImageView.frame.size.width / 2),
//            y: circleLayer.frame.origin.y + (size / 2 - buttonImageView.frame.size.height / 2),
//            width: buttonImageView.frame.size.width,
//            height: buttonImageView.frame.size.height
//        )
//        addSubview(buttonImageView)
    }
}

//extension BearTransitViewController {
//    fileprivate func prepareFABButton() {
//        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
//        fabButton.pulseColor = .white
//        fabButton.backgroundColor = Color.red.base
//    }
//
//    fileprivate func prepareNotesFABMenuItem() {
//        notesFABMenuItem = FABMenuItem()
//        notesFABMenuItem.title = "Audio Library"
//        notesFABMenuItem.fabButton.image = Icon.cm.pen
//        notesFABMenuItem.fabButton.tintColor = .white
//        notesFABMenuItem.fabButton.pulseColor = .white
//        notesFABMenuItem.fabButton.backgroundColor = Color.green.base
//        notesFABMenuItem.fabButton.addTarget(self, action: #selector(handleNotesFABMenuItem(button:)), for: .touchUpInside)
//    }
//
//    fileprivate func prepareRemindersFABMenuItem() {
//        remindersFABMenuItem = FABMenuItem()
//        remindersFABMenuItem.title = "Reminders"
//        remindersFABMenuItem.fabButton.image = Icon.cm.bell
//        remindersFABMenuItem.fabButton.tintColor = .white
//        remindersFABMenuItem.fabButton.pulseColor = .white
//        remindersFABMenuItem.fabButton.backgroundColor = Color.blue.base
//        remindersFABMenuItem.fabButton.addTarget(self, action: #selector(handleRemindersFABMenuItem(button:)), for: .touchUpInside)
//    }
//
//    fileprivate func prepareFABMenu() {
//        fabMenu.fabButton = fabButton
//        fabMenu.fabMenuItems = [notesFABMenuItem, remindersFABMenuItem]
//        fabMenuBacking = .none
//
//        view.layout(fabMenu)
//            .bottom(bottomInset)
//            .right(rightInset)
//            .size(fabMenuSize)
//    }
//}
//
//extension BearTransitViewController {
//    @objc
//    fileprivate func handleNotesFABMenuItem(button: UIButton) {
//        transition(to: NotesViewController())
//        fabMenu.close()
//        //fabMenu.fabButton?.animate(.rotate(0))
//    }
//
//    @objc
//    fileprivate func handleRemindersFABMenuItem(button: UIButton) {
//        transition(to: RemindersViewController())
//        fabMenu.close()
//        //fabMenu.fabButton?.animate(.rotate(0))
//    }
//}
//
//extension BearTransitViewController {
//    @objc
//    open func fabMenuWillOpen(fabMenu: FABMenu) {
//        //fabMenu.fabButton?.animate(.rotate(45))
//
//        print("fabMenuWillOpen")
//    }
//
//    @objc
//    open func fabMenuDidOpen(fabMenu: FABMenu) {
//        print("fabMenuDidOpen")
//    }
//
//    @objc
//    open func fabMenuWillClose(fabMenu: FABMenu) {
//        //fabMenu.fabButton?.animate(.rotate(0))
//
//        print("fabMenuWillClose")
//    }
//
//    @objc
//    open func fabMenuDidClose(fabMenu: FABMenu) {
//        print("fabMenuDidClose")
//    }
//
//    @objc
//    open func fabMenu(fabMenu: FABMenu, tappedAt point: CGPoint, isOutside: Bool) {
//        print("fabMenuTappedAtPointIsOutside", point, isOutside)
//
//        guard isOutside else {
//            return
//        }
//
//        // Do something ...
//    }
//}
