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
class BearTransitViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.width, height: 115)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearestBuses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nearestBusCell", for: indexPath) as! nearBusCollectionCell
        let nearestB = nearestBuses[indexPath.row]
        let toset: [UILabel] = [cell.shortestTime, cell.mediumTime, cell.smallTime]
        let tosetmins: [UILabel] = [cell.min1, cell.min2, cell.min3]
        let timesList = nearestB.timeLeft
        for i in 0...2 {
//            if nearestB.busName == "No Buses Available" {
////                toset[i].isHidden = true
////                tosetmins[i].isHidden = true
//            } else {
                if timesList.count > i {
                    toset[i].text = timesList[i].components(separatedBy: ":")[0]
                } else {
                    toset[i].text = "--"
                }

        }
        cell.busName.text = nearestB.busName
        cell.busDescriptor.text = nearestB.directionTitle

        return cell
    }
    
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
        if let coord = manager.location?.coordinate {
        startLat = [coord.latitude, coord.longitude]
        }
        
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
//        busesNotAvailable.isHidden = true
        self.routesTable.isHidden = true
//        nearestBusesTable.isHidden = true
        nearestBusCollection.isHidden = true
        goButton.isHidden = true
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
        nearestBusCollection.delegate = self
        nearestBusCollection.dataSource = self
        goButton.setTitle("Go", for: .normal)
        zoomToLoc()
        alertImage.image = #imageLiteral(resourceName: "alert").withRenderingMode(.alwaysTemplate).tint(with: .white)
//        alertImage.image?.tint(with: .white)
        noRoutesFound.isHidden = true
        makeMaterialShadow(withView: noRoutesFound)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLiveBuses), userInfo: nil, repeats: true)
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
        //Get Array In Order Of Soonest of Bus Name, Start Time, End Time Bus Name, Full Routes with latitude and longitudes
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
                        var lon1 = self.routes[0].stops[stopIndex].longitude
                        var lat1 = self.routes[0].stops[stopIndex].latitude
                        averageLatLon[0] += lat1
                        averageLatLon[1] += lon1
                        self.drawPath(self.routes[0].stops[stopIndex], self.routes[0].stops[stopIndex + 1])
                    }
                    var lon1 = self.routes[0].stops[self.routes[0].stops.count - 1].longitude
                    var lat1 = self.routes[0].stops[self.routes[0].stops.count - 1].latitude
                    averageLatLon[0] += lat1
                    averageLatLon[1] += lon1
                    averageLatLon[0] /= Double(self.routes[0].stops.count)
                    averageLatLon[1] /= Double(self.routes[0].stops.count)
                    let loc: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: averageLatLon[0], longitude: averageLatLon[1])
                    self.mapView.animate(toLocation: loc)
                    self.mapView.animate(toZoom: 14)
                    
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: self.routes[0].stops[0].latitude, longitude: self.routes[0].stops[0].longitude)
                    marker.icon = #imageLiteral(resourceName: "blueStop").withRenderingMode(.alwaysTemplate).tint(with: Color.green.accent3)
                    marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5);
                    marker.map = self.mapView
                    let smarker = GMSMarker()
                    smarker.position = CLLocationCoordinate2D(latitude: self.routes[0].stops[self.routes[0].stops.count - 1].latitude, longitude: self.routes[0].stops[self.routes[0].stops.count - 1].longitude)
                    smarker.map = self.mapView
                    smarker.icon = #imageLiteral(resourceName: "blueStop").withRenderingMode(.alwaysTemplate).tint(with: Color.red.accent3)
                    self.routesTable.isHidden = false
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
    {   var averageLatLon = [0.0, 0.0]
        var count = 0
        let origin = "\(startStop.latitude),\(startStop.longitude)"
        let destination = "\(destStop.latitude),\(destStop.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyBC8l95akDNvy_xZqa4j3XJCuATi2wFP_g"
        
        Alamofire.request(url).responseJSON { response in
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
                    count += 1
                }
                polyline.strokeWidth = 6
                polyline.strokeColor = self.lightBlue
                polyline.map = self.mapView
                self.polylines.append(polyline)
            }
            

            
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
            marker.icon = #imageLiteral(resourceName: "blueStop")
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
                var c: [NSLayoutConstraint] = dropDown.constraints
                for constraint in c {
                    print(constraint.constant)
                }
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
                self.markers = []
                for bus in buses! {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: bus.latitude as! CLLocationDegrees, longitude: bus.longitude as! CLLocationDegrees)
                    marker.title = bus.lineName
                    marker.icon = #imageLiteral(resourceName: "bus-icon-blue")
                    marker.isFlat = true
                    if (marker.title != "") {
                        marker.map = self.mapView
                    }
                    self.markers.append(marker)
                }
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
//        marker.icon = #imageLiteral(resourceName: "whiteStop")
//        for marker in whitedIcons {
//            marker.icon = #imageLiteral(resourceName: "blueStop")
//        }
//        whitedIcons = []
//        whitedIcons.append(marker)
        if let s = marker.snippet {
            self.routesTable.isHidden = true
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
//            self.nearestBusesTable.backgroundView = activityIndicatorView
            self.activityIndicatorView = activityIndicatorView
            self.activityIndicatorView.startAnimating()
            nearestStopsDataSource.fetchBuses({ (_ buses: [nearestBus]?) in
                if (buses == nil || buses?.count == 0)
                {
                    self.nearestBusCollection.isHidden = false
                    var nb = nearestBus.init(directionTitle: "--", busName: "No Buses Available", timeLeft: "--")
                    self.nearestBuses = [nb]
                    self.nearestBusCollection.reloadData()
//                    self.busesNotAvailable.isHidden = false
//                    self.busesNotAvailable.text = "No buses servicing this stop in the near future"
                    
                } else {
                    self.nearestBusCollection.isHidden = false
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
}
