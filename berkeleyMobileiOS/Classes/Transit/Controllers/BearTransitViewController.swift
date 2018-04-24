//
//  BearTransitViewController.swift
//  berkeleyMobileiOS
//
//  Start page of Transit.
//  Allows user to search for bus route between start and end destination
//  Also provides on-map pathing for bus route and utility information (microwave, water, nap pods)
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

// Marker class for utilities
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

class BearTransitViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {

    // Main UI Elements
    @IBOutlet var stopTimeButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var destView: UIView!
    @IBOutlet weak var block1: UIView!
    @IBOutlet weak var block2: UIView!
    @IBOutlet weak var noRoutesFound: UIView!
    @IBOutlet weak var alertImage: UIImageView!
    
    // drop down for autofill on text fields
    var dropDown: DropDown?
    var endDropDown: DropDown?
   
    // For route pathing
    var routes: [Route] = []
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var markers:[GMSMarker] = []
    let defaultCoord: [Double] = [37.871853, -122.258423]
    var startLat: [Double] = [37.871853, -122.258423]
    var stopLat: [Double] = [37.871853, -122.258423]
    var selectedIndexPath = 0
    var polylines:[GMSPolyline] = []
    var whitedIcons:[GMSMarker] = []
    var liveBusMarkers: [String: GMSMarker] = [:]
    
    // colors
    var darkBlue = UIColor.init(red: 2/255, green: 46/255, blue: 129/255, alpha: 1)
    var lightBlue = UIColor.init(red: 38/255, green: 133/255, blue: 245/255, alpha: 1)
    
    // date formatters
    var serverToLocalFormatter = DateFormatter.init()
    var timeFormatter = DateFormatter.init()
    
    var nearestBuses: [nearestBus] = []
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    // UI Elements for utilities
    @IBOutlet weak var iconInfoView: UIView!
    @IBOutlet weak var distanceFromUserDisplay: UILabel!
    @IBOutlet weak var selectedIconDisplay: UIImageView!
    @IBOutlet weak var iconTitleDisplay: UILabel!
    @IBOutlet weak var colorDisplay: UIView!
    @IBOutlet weak var info1DisplayLabel: UILabel!
    @IBOutlet weak var info2DisplayLabel: UILabel!
    
    let menuButtonSize: CGSize = CGSize(width: 75.0, height: 75.0)
    var menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 75.0, height: 75.0)), centerImage:  #imageLiteral(resourceName: "white_eye"), centerHighlightedImage: #imageLiteral(resourceName: "white_eye"))
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        iconInfoView.isHidden = true
        menuButton.isHidden = false
    }
    
    // Used for Utility Icons
    var pressed: Bool = true
    var dict: [String : [[String : Any]]] = [String : [[String : Any]]]()
    var microwaVeCoordinates = [LocationMarkersData]()
    var waterFountainCoordinates = [LocationMarkersData]()
    var napPodsCoordinates = [LocationMarkersData]()
    var selectedIcons = [LocationMarkersData]()
    var chosenMarkers = [GMSMarker]()
    
    
    //**********************************
    // Views and Segues
    //**********************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCoordinates()
        self.mapView.delegate = self
        setupMap()
        setupStartDestFields()
        setupLocationManager()
        setupTimeFormatters()
        setupUI()
        zoomToLoc()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLiveBuses), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (startField.text == "Current Location") {
            if let coord = manager.location?.coordinate {
                startLat = [coord.latitude, coord.longitude]
            }
        }
        Analytics.logEvent("opened_transit_screen", parameters: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! RouteResultViewController
        dest.routes = self.routes
        dest.start = startField.text
        dest.end = destinationField.text
        Analytics.logEvent("clicked_on_route", parameters: nil)
    }
    
    
    //**********************************
    // Setup Functions
    //**********************************
    
    func setupMap() {
        //Setting up map view
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
    }
    
    func setupStartDestFields() {
        self.makeMaterialShadow(withView: destView)
        self.makeMaterialShadow(withView: stopTimeButton)
        self.makeMaterialShadow(withView: goButton)
        startField.delegate = self
        destinationField.delegate = self
        configureDropDown()
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
    
    func setupUI() {
        self.goButton.applyGradient(colours: [darkBlue, lightBlue])
        self.stopTimeButton.applyGradient(colours: [darkBlue, lightBlue])
        self.destView.cornerRadius = 5.0
        self.stopTimeButton.layer.cornerRadius = 5.0
        self.goButton.layer.cornerRadius = 5.0
        
        block1.layer.cornerRadius = 0.5*block1.frame.width
        block2.layer.cornerRadius = 0.5*block2.frame.width
        
        stopTimeButton.setTitleColor(UIColor.white, for: .normal)
        stopTimeButton.isHidden = true
        goButton.setTitle("Go", for: .normal)
        
        alertImage.image =  #imageLiteral(resourceName: "alert").withRenderingMode(.alwaysTemplate).tint(with: .white)
        noRoutesFound.isHidden = true
        makeMaterialShadow(withView: noRoutesFound)
        
        // utilities
        iconInfoView.isHidden = true
        iconInfoView.clipsToBounds = true
        mapView.addSubview(iconInfoView)
        
        menuButton.center = CGPoint(x: self.view.bounds.width - 44.0, y: self.view.bounds.height - 100.0)
        menuButton.menuItemMargin = 10
        menuButton.allowSounds = false
        
        view.addSubview(menuButton)
        setupUtilities(menuButton: menuButton)
    }
    
    func makeMaterialShadow(withView tf: UIView!) {
        tf.layer.masksToBounds = false
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowColor = Color.gray.cgColor
        tf.layer.shadowOffset = CGSize(width: 1, height: 1)
        tf.layer.shadowOpacity = 1
    }
    
    func setupUtilities(menuButton : ExpandingMenuButton) {
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "", image: #imageLiteral(resourceName: "water_fountains"), highlightedImage: #imageLiteral(resourceName: "water_fountains"), backgroundImage: #imageLiteral(resourceName: "water_fountains"), backgroundHighlightedImage: #imageLiteral(resourceName: "water_fountains")) { () -> Void in
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": "Waterfountain"])
            self.markers.append(contentsOf: self.chosenMarkers)
            self.chosenMarkers.removeAll()
            self.getCoordinates()
            for coordinate in self.waterFountainCoordinates {
                let latitude =  Double(coordinate.lat)
                let longitude =  Double(coordinate.lon)
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                let marker = GMSMarker(position: location.coordinate)
                marker.map = self.mapView
                marker.title = coordinate.building
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "water_fountains"), scaledToSize: CGSize(width: 50.0, height: 50.0))
                self.chosenMarkers.append(marker)
            }
            self.selectedIcons = self.waterFountainCoordinates
        }
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "", image: #imageLiteral(resourceName: "microwaves"), highlightedImage: #imageLiteral(resourceName: "microwaves"), backgroundImage: #imageLiteral(resourceName: "microwaves"), backgroundHighlightedImage: #imageLiteral(resourceName: "microwaves")) { () -> Void in
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": "Microwave"])
            
            self.markers.append(contentsOf: self.chosenMarkers)
            self.chosenMarkers.removeAll()
            self.getCoordinates()
            for coordinate in self.microwaVeCoordinates {
                let latitude =  Double(coordinate.lat)
                let longitude =  Double(coordinate.lon)
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                let marker = GMSMarker(position: location.coordinate)
                marker.map = self.mapView
                marker.title = coordinate.building
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "microwaves"), scaledToSize: CGSize(width: 50.0, height: 50.0))
                self.chosenMarkers.append(marker)
            }
            self.selectedIcons = self.microwaVeCoordinates
        }
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: "", image: #imageLiteral(resourceName: "nap_pods"), highlightedImage: #imageLiteral(resourceName: "nap_pods"), backgroundImage: #imageLiteral(resourceName: "nap_pods"), backgroundHighlightedImage: #imageLiteral(resourceName: "nap_pods")) { () -> Void in
            Analytics.logEvent("map_icon_clicked", parameters: ["Category": "Nappod"])
            
            self.markers.append(contentsOf: self.chosenMarkers)
            self.chosenMarkers.removeAll()
            self.getCoordinates()
            for coordinate in self.napPodsCoordinates {
                let latitude =  Double(coordinate.lat)
                let longitude =  Double(coordinate.lon)
                let location = CLLocation(latitude: latitude!, longitude: longitude!)
                let marker = GMSMarker(position: location.coordinate)
                marker.map = self.mapView
                marker.title = coordinate.building
                marker.icon = self.imageWithImage(image: #imageLiteral(resourceName: "nap_pods"), scaledToSize: CGSize(width: 50.0, height: 50.0))
                self.chosenMarkers.append(marker)
            }
            self.selectedIcons = self.napPodsCoordinates
        }
        
        menuButton.addMenuItems([item1, item2, item3])
    }
    
    func zoomToLoc() {
        if let coord = manager.location?.coordinate {
            startLat = [coord.latitude, coord.longitude]
        }
        zoomToCurrentLocation()
    }
    
    func zoomToCurrentLocation() {
        if let coord = manager.location?.coordinate {
            self.mapView.animate(toLocation: CLLocationCoordinate2D.init(latitude: coord.latitude, longitude: coord.longitude))
            self.mapView.animate(toZoom: 16.5)
        }
    }
    
    
    //**********************************
    // Find Routes and Draw on Map
    //**********************************
    
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
            for p in polylines{
                p.map = nil
            }
            
            turnStopsOFF()
            polylines = []
            self.goButton.setTitle("Loading", for: .normal)
            fullRouteDataSource.fetchBuses({ (routesArray: [Route]!) in
                self.routes = routesArray!
                if (self.routes.count == 0) {
                    self.noRoutesFound.isHidden = false
                } else {
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
                    self.performSegue(withIdentifier: "routeResults", sender: self)
                }
                self.goButton.setTitle("Done", for: .normal)
            }, startLat: String(self.startLat[0]), startLon: String(self.startLat[1]), destLat: String(self.stopLat[0]), destLon: String(self.stopLat[1]))
            
            self.goButton.layer.sublayers?.removeFirst()
            goButton.setTitleColor(darkBlue, for: .normal)
        } else {
            for p in polylines{
                p.map = nil
            }
            turnStopsOFF()
            self.noRoutesFound.isHidden = true
            goButton.setTitle("Go", for: .normal)
            self.goButton.applyGradient(colours: [darkBlue, lightBlue])
            goButton.setTitleColor(UIColor.white, for: .normal)
        }
        
    }
    
    
    func drawPath(_ startStop: routeStop, _ destStop: routeStop)
    {
        let origin = "\(startStop.latitude),\(startStop.longitude)"
        let destination = "\(destStop.latitude),\(destStop.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyBC8l95akDNvy_xZqa4j3XJCuATi2wFP_g"
        if (startStop.id == 15382 && destStop.id == 15383) {
            let pat = GMSMutablePath.init()
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
                let json = JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 6
                    polyline.strokeColor = self.lightBlue
                    polyline.map = self.mapView
                    self.polylines.append(polyline)
                }
            }
        }
        
        
    }
    
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
    
    func updateLiveBuses() {
        livebusDataSource.fetchBuses({ (_ buses: [livebus]?) in
            if (buses == nil || buses?.count == 0)
            {
                
            } else {
                for m in self.markers {
                    m.map = nil
                }
                self.markers.removeAll()
                var new_buses: [String: GMSMarker] = [:]
                for bus in buses! {
                    if bus.lineName == "" {
                        continue
                    }
                    if self.liveBusMarkers.keys.contains(bus.id) {
                        self.liveBusMarkers[bus.id]!.position = CLLocationCoordinate2D(latitude: bus.latitude , longitude: bus.longitude)
                        new_buses[bus.id] = self.liveBusMarkers[bus.id]!
                    } else {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: bus.latitude , longitude: bus.longitude)
                        marker.title = bus.lineName
                        marker.icon =  #imageLiteral(resourceName: "bus-icon-blue")
                        marker.isFlat = true
                        marker.map = self.mapView
                        new_buses[bus.id] = marker
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
    
    
    //**********************************
    // Map View Functions
    //**********************************
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideKeyBoard()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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
        } else {
            return true
        }

        self.selectedIconDisplay.image = selected?.icon
        self.iconTitleDisplay.text = title
        self.iconTitleDisplay.textColor = color
        self.colorDisplay.backgroundColor = color
        self.info1DisplayLabel.text = selected?.building
        self.info2DisplayLabel.text = selected?.floor

        return false
    }
    
    
    
    //**********************************
    // Toggle (Conditional) Helper Functions
    //**********************************
    
    @IBAction func toggleStops(_ sender: Any) {
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
        self.populateMapWithStops()
        pressed = true
        stopTimeButton.applyGradient(colours: [darkBlue, lightBlue])
        stopTimeButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func turnStopsOFF() {
        self.mapView.clear()
        pressed = false
    }
    
    func displayGoButtonOnCondition() {
        if (startLat != defaultCoord && stopLat != defaultCoord) {
            goButton.isHidden = false
        }
    }
    
    func toggleHidden(someView:UIView!) {
        someView.isHidden = !(someView.isHidden)
    }
    
    
    //**********************************
    // Text Field and Drop Down Functions
    //**********************************
    
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
        enddropper.backgroundColor = UIColor.white
        self.endDropDown = enddropper
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
    
    func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        startField.endEditing(true)
        destinationField.endEditing(true)
    }
    
    
    //**********************************
    // Utility Icon Helper Functions
    //**********************************
    
    func getCoordinates() {
        let apiToContact = "http://asuc-mobile-dev.herokuapp.com/api/map"
        Alamofire.request(apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    self.dict = value as! [String : [[String : Any]]]
                    
                    //WaterFountain Coordinates
                    let waterData = self.dict["Water Fountain"]!
                    for loc in waterData {
                        let finalData = loc
                        let location = LocationMarkersData()
                        if let c = finalData["description2"]! as? String {
                            location.setFloor(text: c)
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
                            location.setFloor(text: c)
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
                                location.setFloor(text: c)
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
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func getSelectedMarker(name: String) -> LocationMarkersData? {
        for marker in selectedIcons {
            if marker.building == name {
                return marker
            }
        }
        return nil
    }
    
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
