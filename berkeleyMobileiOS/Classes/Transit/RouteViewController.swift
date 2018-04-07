//
//  RouteViewController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 3/5/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire

class RouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate {

    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var exitButton: IconButton!
    
    var selectedRoute: Route!
    
    var busType:String!
    var name:String!
    var bus1:Int!
    var bus2:Int!
    var duration:String!
    var time:String!
    
    // for drawing path
    var lightBlue = UIColor.init(red: 38/255, green: 133/255, blue: 245/255, alpha: 1)
    var polylines:[GMSPolyline] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        exitButton.image = Icon.arrowBack?.tint(with: .black)
        setupMap()
        // Do any additional setup after loading the view.
    }
    
    func setupMap() {
        var averageLatLon = [0.0, 0.0]
        for stopIndex in 0...(self.selectedRoute.stops.count - 2) {
            let lon1 = self.selectedRoute.stops[stopIndex].longitude
            let lat1 = self.selectedRoute.stops[stopIndex].latitude
            averageLatLon[0] += lat1
            averageLatLon[1] += lon1
            self.drawPath(self.selectedRoute.stops[stopIndex], self.selectedRoute.stops[stopIndex + 1])
            if stopIndex != 0 {
                let marker4 = GMSMarker()
                marker4.icon = #imageLiteral(resourceName: "bluecircle").resize(toWidth: 18)
                let loc = CLLocationCoordinate2D.init(latitude: lat1, longitude: lon1)
                marker4.position = loc
                marker4.snippet = self.selectedRoute.stops[stopIndex].name
                marker4.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
                marker4.map = self.mapView
            }
            
        }
        let lon1 = self.selectedRoute.stops[self.selectedRoute.stops.count - 1].longitude
        let lat1 = self.selectedRoute.stops[self.selectedRoute.stops.count - 1].latitude
       
        averageLatLon[0] += lat1
        averageLatLon[1] += lon1
        averageLatLon[0] /= Double(self.selectedRoute.stops.count)
        averageLatLon[1] /= Double(self.selectedRoute.stops.count)
        let loc: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: averageLatLon[0], longitude: averageLatLon[1])
        self.mapView.animate(toLocation: loc)
        self.mapView.animate(toZoom: 14)
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.selectedRoute.stops[0].latitude, longitude: self.selectedRoute.stops[0].longitude)
        marker.icon = #imageLiteral(resourceName: "blueStop").withRenderingMode(.alwaysTemplate).tint(with: Color.green.accent3)
        marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5);
        marker.map = self.mapView
        let smarker = GMSMarker()
        smarker.position = CLLocationCoordinate2D(latitude: self.selectedRoute.stops[self.selectedRoute.stops.count - 1].latitude, longitude: self.selectedRoute.stops[self.selectedRoute.stops.count - 1].longitude)
        smarker.map = self.mapView
        smarker.icon = #imageLiteral(resourceName: "blueStop").withRenderingMode(.alwaysTemplate).tint(with: Color.red.accent3)
    }
    
    func drawPath(_ startStop: routeStop, _ destStop: routeStop)
    {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedRoute.twoTrips) {
            return 2
        } else {
            return 1
        }
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return selectedRoute.busName
//        } else {
//            return selectedRoute.secondBusName
//        }
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selectedRoute.stops.count
        } else {
            return selectedRoute.secondRouteStops!.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 120
        } else {
            return 65
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        tableView.register(nearestBusTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        var stopToDisplay: routeStop
        if indexPath.section == 0 {
            stopToDisplay = selectedRoute.stops[indexPath.row]
        } else {
            stopToDisplay = (selectedRoute.secondRouteStops?[indexPath.row])!
        }
        
//        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! RouteTitleTableViewCell
            cell.busLabel.text = busType
            cell.timeLabel.text = duration
            
            var b = selectedRoute.busName
            switch b {
            case "Southside Line":
                b = "SOUTH"
            case "Northside Line":
                b = "NORTH"
            case "Perimeter Line":
                b = "PRMTR"
            case "Central Line":
                b = "CNTRL"
            default:
                b = "LINE"
            }
            
            cell.busStartNum.text = b
            if (selectedRoute.twoTrips) {
                var b2 = selectedRoute.secondBusName!
                switch b2 {
                case "Southside Line":
                    b2 = "SOUTH"
                case "Northside Line":
                    b2 = "NORTH"
                case "Perimeter Line":
                    b2 = "PRMTR"
                case "Central Line":
                    b2 = "CNTRL"
                default:
                    b2 = "LINE"
                }
                cell.busEndNum.text = b2
            } else {
                cell.busEndNum.isHidden = true
                cell.bus2.isHidden = true
                cell.arrow.isHidden = true
            }
            
            
//            cell.busStartNum.text = "\(bus1)"
//            cell.busStartNum.text = "\(bus2)"
            return cell
//        }
//        } else if indexPath.row == 1 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "startCell", for: indexPath) as! RouteDetailsTableViewCell
//            cell.stopName.text = stopToDisplay.name
//            cell.timeLabel.text = time
//            return cell
//        }
//        else if ((indexPath.row == (selectedRoute?.stops.count)! - 1) && (indexPath.section == 0)) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "endCell", for: indexPath) as! RouteEndTableViewCell
//            cell.stopName.text = stopToDisplay.name
//            if (selectedRoute.twoTrips) {
//                cell.transferImage.isHidden = false
//            } else {
//                cell.transferImage.isHidden = true
//            }
//            return cell
//        } else if (indexPath.section == 1) {
//            if (indexPath.row == 0) {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "startCell", for: indexPath) as! RouteDetailsTableViewCell
//                cell.stopName.text = stopToDisplay.name
//                cell.timeLabel.text = selectedRoute.startTime2
//                return cell
//            } else if(indexPath.row == (selectedRoute?.secondRouteStops?.count)! - 1) {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "endCell", for: indexPath) as! RouteEndTableViewCell
//                cell.stopName.text = stopToDisplay.name
//                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "midCell", for: indexPath) as! RouteMidTableViewCell
//                cell.stopName.text = stopToDisplay.name
//                return cell
//            }
//        }
//        else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "midCell", for: indexPath) as! RouteMidTableViewCell
//            cell.stopName.text = stopToDisplay.name
//            return cell
//        }



    }
    
    
    @IBAction func exit(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
