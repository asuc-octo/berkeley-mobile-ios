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

class BearTransitViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource {
    //Sets up initial tab look for this class
    @IBOutlet var stopTimeButton: UIButton!
    var dropDown: DropDown?
    var endDropDown: DropDown?
    var routes: [Route] = []
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    @IBOutlet var busesNotAvailable: UILabel!
    @IBOutlet weak var routesTable: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    var serverToLocalFormatter = DateFormatter.init()
    var timeFormatter = DateFormatter.init()
    var pressed: Bool = true
    var nearestBuses: [nearestBus] = []
    @IBOutlet var nearestBusesTable: UITableView!
    weak var activityIndicatorView: UIActivityIndicatorView!
    var startLat: [Double] = [37.871853, -122.258423]
    var stopLat: [Double] = [37.871853, -122.258423]
    var selectedIndexPath = 0
    var polylines:[GMSPolyline] = []
    
    @IBAction func toggleStops(_ sender: Any) {
        self.routesTable.isHidden = true
        self.nearestBusesTable.isHidden = true
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
        backgroundQueue.async {
            self.populateMapWithStops()
        }
        pressed = true
        stopTimeButton.setTitleColor(UIColor.init(red: 0/255, green: 85/255, blue: 129/255, alpha: 1), for: .normal)
        stopTimeButton.borderColor = UIColor.init(red: 0/255, green: 85/255, blue: 129/255, alpha: 1)
    }
    func turnStopsOFF() {
        self.mapView.clear()
        pressed = false
        stopTimeButton.setTitleColor(UIColor.gray, for: .normal)
        stopTimeButton.borderColor = UIColor.gray
    }
    func zoomToCurrentLocation() {
        if let coord = manager.location?.coordinate {
            self.mapView.animate(toLocation: CLLocationCoordinate2D.init(latitude: coord.latitude, longitude: coord.longitude))
            self.mapView.animate(toZoom: 16.5)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let coord = manager.location?.coordinate {
        startLat = [coord.latitude, coord.longitude]
        }
        zoomToCurrentLocation()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        busesNotAvailable.isHidden = true
        self.routesTable.isHidden = true
        //Setting up map view
        let camera = GMSCameraPosition.camera(withLatitude: 37.871853, longitude: -122.258423, zoom: 15)
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        // Do any additional setup after loading the view.
        self.makeMaterialShadow(withView: startField)
        self.makeMaterialShadow(withView: destinationField)
        populateMapWithStops()
        startField.delegate = self
        destinationField.delegate = self
        configureDropDown()
        nearestBusesTable.isHidden = true
        serverToLocalFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        serverToLocalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        timeFormatter.dateFormat = "h:mm a"
        serverToLocalFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        if let coord = manager.location?.coordinate {
            startLat = [coord.latitude, coord.longitude]
        }
        zoomToCurrentLocation()
}
    func hideKeyBoard(sender: UITapGestureRecognizer? = nil){
        startField.endEditing(true)
        destinationField.endEditing(true)
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideKeyBoard()
    }
    func configureDropDown() {
        let dropper = DropDown()
        dropper.anchorView = self.startField
        dropper.dismissMode = .onTap
        dropper.bottomOffset = CGPoint(x: 0, y:dropper.anchorView!.plainView.bounds.height)
        dropper.dataSource = ["Start Typing!"]
        dropper.selectionAction = { [unowned self] (index: Int, item: String) in
            self.startField.text = item
            self.startField.resignFirstResponder()
            if ((self.destinationField.text?.characters.count)! > 0 && (self.startField.text != "Enter Destination")) {
                self.goButton.isHidden = false
            }
            self.startLat = self.getLatLngForZip(address: item)
        }
        dropper.width = dropper.anchorView!.plainView.width
        self.dropDown = dropper
        let enddropper = DropDown()
        enddropper.anchorView = self.destinationField
        enddropper.dismissMode = .onTap
        enddropper.bottomOffset = CGPoint(x: 0, y:dropper.anchorView!.plainView.bounds.height)
        enddropper.dataSource = ["Start Typing!"]
        enddropper.selectionAction = { [unowned self] (index: Int, item: String) in
            self.destinationField.text = item
            self.destinationField.resignFirstResponder()
            self.getLatLngForZip(address: item)
            if ((self.startField.text?.characters.count)! > 0 && (self.startField.text != "Enter Start Point")) {
                self.goButton.isHidden = false
            }
            self.stopLat = self.getLatLngForZip(address: item)
        }
        enddropper.width = dropper.anchorView!.plainView.width
        self.endDropDown = enddropper
    }
    @IBAction func toggleStartStop(_ sender: Any) {
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {() -> Void in
            self.toggleHidden(someView: self.startField)
            self.toggleHidden(someView: self.destinationField)

        }, completion: { _ in
            let dropper = DropDown()
            dropper.anchorView = self.startField
            dropper.dismissMode = .onTap
            dropper.bottomOffset = CGPoint(x: 0, y:dropper.anchorView!.plainView.bounds.height)
            dropper.dataSource = ["Start Typing!"]
            dropper.selectionAction = { [unowned self] (index: Int, item: String) in
                self.startField.text = item
                self.startField.resignFirstResponder()
                if ((self.destinationField.text?.characters.count)! > 0 && (self.startField.text != "Enter Destination")) {
                    self.goButton.isHidden = false
                }
                self.startLat = self.getLatLngForZip(address: item)
            }
            dropper.width = dropper.anchorView!.plainView.width
            self.dropDown = dropper
            let enddropper = DropDown()
            enddropper.anchorView = self.destinationField
            enddropper.dismissMode = .onTap
            enddropper.bottomOffset = CGPoint(x: 0, y:dropper.anchorView!.plainView.bounds.height)
            enddropper.dataSource = ["Start Typing!"]
            enddropper.selectionAction = { [unowned self] (index: Int, item: String) in
                self.destinationField.text = item
                self.destinationField.resignFirstResponder()
                self.getLatLngForZip(address: item)
                if ((self.startField.text?.characters.count)! > 0 && (self.startField.text != "Enter Start Point")) {
                    self.goButton.isHidden = false
                }
                self.stopLat = self.getLatLngForZip(address: item)
            }
            enddropper.width = dropper.anchorView!.plainView.width
            self.endDropDown = enddropper
        })
    }
    
    @IBAction func searchRoutes(_ sender: Any) {
        //Get Array In Order Of Soonest of Bus Name, Start Time, End Time Bus Name, Full Routes with latitude and longitudes
        self.routesTable.isHidden = true
        for p in polylines{
            p.map = nil
        }
        self.nearestBusesTable.isHidden = true
        self.busesNotAvailable.isHidden = true
        turnStopsOFF()
        polylines = []
        fullRouteDataSource.fetchBuses({ (routesArray: [Route]!) in
            self.routes = routesArray!
            if (self.routes.count == 0) {
                self.busesNotAvailable.isHidden = false

            } else {
                self.routesTable.reloadData()
                for stopIndex in 0...(self.routes[0].stops.count - 2) {
                    self.drawPath(self.routes[0].stops[stopIndex], self.routes[0].stops[stopIndex + 1])
                }
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: self.routes[0].stops[0].latitude, longitude: self.routes[0].stops[0].longitude)
                    marker.icon = UIImage.init(named: "cl")?.withRenderingMode(.alwaysTemplate).tint(with: Color.green.base)
                    marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5);
                    marker.map = self.mapView
                    let smarker = GMSMarker()
                    smarker.position = CLLocationCoordinate2D(latitude: self.routes[0].stops[self.routes[0].stops.count - 1].latitude, longitude: self.routes[0].stops[self.routes[0].stops.count - 1].longitude)
                    smarker.map = self.mapView
                self.routesTable.isHidden = false
            }
        }, startLat: String(self.startLat[0]), startLon: String(self.startLat[1]), destLat: String(self.stopLat[0]), destLon: String(self.stopLat[1]))
        

    }
    func drawPath(_ startStop: routeStop, _ destStop: routeStop)
    {   var averageLatLon = [0.0, 0.0]
        var count = 0
        let origin = "\(startStop.latitude),\(startStop.longitude)"
        let destination = "\(destStop.latitude),\(destStop.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyBC8l95akDNvy_xZqa4j3XJCuATi2wFP_g"
        
        Alamofire.request(url).responseJSON { response in
//            var firstCoord = [0.0, 0.0]
            var lastCoord = [0.0,0.0]
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                for i in 0...((path?.count())! - 1) {
                    lastCoord = [(path?.coordinate(at: i).latitude)!,(path?.coordinate(at: i).longitude)!]
                    averageLatLon[0] += lastCoord[0]
                    averageLatLon[1] += lastCoord[1]

//                    if fBool {
//                        firstCoord = averageLatLon
//                        fBool = false
//                    }
                    count += 1
                }
                polyline.strokeWidth = 5
                polyline.strokeColor = UIColor.init(red: 0/255, green: 85/255, blue: 129/255, alpha: 1)
                polyline.map = self.mapView
                self.polylines.append(polyline)
            }
            

            averageLatLon[0] /= Double(count)
            averageLatLon[1] /= Double(count)
            self.mapView.animate(toLocation: CLLocationCoordinate2D.init(latitude: averageLatLon[0] + 0.003, longitude: averageLatLon[1]))
            self.mapView.animate(toZoom: 14.5)
            
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! RouteViewController
        dest.selectedRoute = self.routes[selectedIndexPath]
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.goButton.isHidden = true
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
            marker.icon = UIImage.init(named: "Marker-1")
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
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let s = marker.snippet {
            self.routesTable.isHidden = true
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            self.nearestBusesTable.backgroundView = activityIndicatorView
            self.activityIndicatorView = activityIndicatorView
            self.activityIndicatorView.startAnimating()
            nearestStopsDataSource.fetchBuses({ (_ buses: [nearestBus]?) in
                if (buses == nil || buses?.count == 0)
                {
                    self.nearestBusesTable.isHidden = true
                    self.busesNotAvailable.isHidden = false
                    self.busesNotAvailable.text = "No buses servicing this stop in the near future"
                    
                } else {
                    self.busesNotAvailable.isHidden = true
                    self.nearestBuses = buses!
                    self.nearestBusesTable.reloadData()
                    self.activityIndicatorView.stopAnimating()
                    self.nearestBusesTable.isHidden = false
                }
                
            }, stopCode:s)
        } else {
            
        }
        return false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return self.routes.count
        } else {
            return self.nearestBuses.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! routeCell
            let route: Route = routes[indexPath.row]
            cell.lineName.text = route.busName
            let Routecount = route.stops.count
            cell.start.text = route.stops[0].name
            cell.end.text = route.stops[Routecount - 1].name
            let currentDate = serverToLocalFormatter.date(from: route.startTime)
            cell.timeTravel.text = timeFormatter.string(from: currentDate!)
            //        cell.detailTextLabel!.text = currentBus.directionTitle
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearestBusesTableViewCell") as! NearestBusesTableViewCell
            let nearestB = nearestBuses[indexPath.row]
            cell.busName.text = nearestB.busName
            cell.busLabel.text = nearestB.directionTitle
            cell.nearestBus = nearestB
            cell.timesCollection.delegate = cell
            cell.timesCollection.dataSource = cell
            cell.timesCollection.reloadData()
            return cell
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            performSegue(withIdentifier: "routeDetails", sender: self)
        }
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
