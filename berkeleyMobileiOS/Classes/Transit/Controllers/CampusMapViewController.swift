//
//  CampusMapViewController.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 1/1/19.
//  Copyright © 2019 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class CampusMapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var campusMapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var shortcutCollectionView: UICollectionView!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailSubtitle1: UILabel!
    @IBOutlet weak var detailSubtitle2: UILabel!
    @IBOutlet weak var detailSubtitle3: UILabel!
    @IBOutlet weak var detailSubtitle4: UILabel!
    @IBOutlet weak var detailColor: UIView!
    @IBOutlet weak var busLineSegmentedControl: UISegmentedControl!
    var detailBigAnchor: NSLayoutConstraint!
    var detailSmallAnchor: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    
    
    
    
    var shortcutStackView: UIStackView!
    var shortcutView: UIView!
    let campusMapModel = CampusMapModel()
    var mapMarkers: [String: [MKPinAnnotationView]] = [:]
    
    var selectedLocation: Location? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get rid of searchBar background
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
        campusMapView.delegate = self
        registerMapAnnotationViews()
        
        centerMapOnLocation(location: CLLocation(latitude: 37.871853, longitude: -122.258423))
        CampusMapDataSource.getLocations()
        shortcutCollectionView.register(UINib(nibName: "ShortcutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        shortcutCollectionView.delegate = self
        shortcutCollectionView.dataSource = self
        
        detailView.isHidden = true
        detailView.translatesAutoresizingMaskIntoConstraints = false

        campusMapView.addAnnotations(populateBusStops())
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        campusMapView.showsUserLocation = true
        
        detailBigAnchor = detailView.heightAnchor.constraint(equalToConstant: 180)
        detailSmallAnchor = detailView.heightAnchor.constraint(equalToConstant: 100)
    }
        
        
        
    
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
        pageTabBarItem.image = UIImage(named: "beartransit")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            print("location:: (location)")
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }

    
    func searchBarSearchButtonClicked(_ bar: UISearchBar) {
        campusMapView.removeAnnotations(campusMapView.annotations)
        bar.resignFirstResponder()
        guard let text = bar.text else { return }
        let locations = campusMapModel.search(for: text)
        campusMapView.addAnnotations(locations)
    }
    
    func searchBarTextDidBeginEditing(_ bar: UISearchBar) {
     }
    
    func centerMapOnLocation(location: CLLocation) {
        let mapRadius: Double = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, mapRadius, mapRadius)
        campusMapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CampusMapModel.shortcutsAndIconNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = shortcutCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ShortcutCollectionViewCell {
            let cellImage = UIImage(named: CampusMapModel.shortcutsAndIconNames[indexPath.item].1)
            cell.shortcutImage.image = cellImage
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchString = CampusMapModel.shortcutsAndIconNames[indexPath.item].0
        searchBar.text = searchString
        searchBarSearchButtonClicked(searchBar)
    }
    
    private func registerMapAnnotationViews() {
        for identifier in CampusMapModel.shortcutToIconNames.keys {
            campusMapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let location = annotation as? Location {
            if let fileName = CampusMapModel.shortcutToIconNames[location.type] {
                if let image = UIImage(named: fileName), let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: location.type)
                {
                    var annotationImage = image.resize(toWidth: 20)
                    annotationImage = annotationImage!.resize(toHeight: 20)
                    annotationView.image = annotationImage
                    annotationView.canShowCallout = true

                    
                    return annotationView
                }
            }
        }
        
        if let _ = annotation as? MKUserLocation {
            return nil
        }
        
        return MKAnnotationView()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        busLineSegmentedControl.isHidden = true
        
        var needToGrow = false
        var resetFont = true
        
        if let location = view.annotation as? Location {
            growDetailView()
            selectedLocation = location
            
            detailSubtitle1.text = ""
            detailSubtitle2.text = ""
            detailSubtitle3.text = ""
            detailSubtitle4.text = ""
            
            switch location.type {
            case "Mental Health Resource":
                detailColor.backgroundColor = UIColor(red: 245, green: 210, blue: 71, alpha: 1)
            case "Printer":
                detailColor.backgroundColor = UIColor(red: 117, green: 184, blue: 85, alpha: 1)
            case "Water Fountain":
                detailColor.backgroundColor = UIColor(red: 97, green: 181, blue: 207, alpha: 1)
            case "Microwave":
                detailColor.backgroundColor = UIColor(red: 238, green: 121, blue: 50, alpha: 1)
            case "Nap Pod":
                detailColor.backgroundColor = UIColor(red: 233, green: 70, blue: 165, alpha: 1)
            case "Ford Go Bike":
                detailColor.backgroundColor = UIColor(red: 41, green: 63, blue: 245, alpha: 1)
            default:
                detailColor.backgroundColor = .clear
            }
            
            if let imageName = CampusMapModel.shortcutToIconNames[location.type] {
                 detailImage.image = UIImage(named: imageName)
            }
            
            detailTitle.text = location.title
            
            if let (bool, time) = location.isOpen() {
                resetFont = false
                detailSubtitle1.text = bool ? "Open" : "Closed"
                
                if bool {
                    detailSubtitle1.textColor = .green
                } else {
                    detailSubtitle1.textColor = .red
                }
                detailSubtitle2.text = time
                detailSubtitle2.font = UIFont.systemFont(ofSize: 13)
                detailSubtitle2.textColor = UIColor.lightGray
                
                if let moreInfo = location.moreInfo {
                    needToGrow = true
                    detailSubtitle3.text = moreInfo
                }
                
                if let notes = location.notes {
                    needToGrow = true
                    detailSubtitle4.text = notes
                }
            } else {
                needToGrow = false
                
                if let moreInfo = location.moreInfo {
                    detailSubtitle1.text = moreInfo
                }
                
                if let notes = location.notes {
                    detailSubtitle2.text = notes
                }
            }
            
            if let busStop = location as? BusStop {
                needToGrow = true
                busLineSegmentedControl.removeAllSegments()
                
                for i in 0..<busStop.busLines.count {
                    busLineSegmentedControl.insertSegment(withTitle: busStop.busLines[i], at: i, animated: true)
                }
                
                busLineSegmentedControl.selectedSegmentIndex = 0
                busLineSegmentedControl.isHidden = false
                busLineChanged(busLineSegmentedControl)
            }
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.detailView.alpha = 0.9
            self.shortcutCollectionView.alpha = 0
        }) { (success) in
            self.detailView.isHidden = false
            self.shortcutCollectionView.isHidden = true
           
        }
        
        needToGrow ? growDetailView() : shrinkDetailView()
        
        if resetFont {
            detailSubtitle1.textColor = .black
            detailSubtitle2.textColor = .black
            detailSubtitle2.font = UIFont.systemFont(ofSize: 17)
        }
    }
    
    @IBAction func busLineChanged(_ sender: UISegmentedControl) {
        if let stop = selectedLocation as? BusStop {
            let selectedIndex = sender.selectedSegmentIndex >= 0 ? sender.selectedSegmentIndex : 0
            let lineName = sender.titleForSegment(at: selectedIndex)!
            
            detailSubtitle1.text = "Next Bus:"
            if let lineDirections = lineDirections[lineName] {
                detailSubtitle1.text = "Next Bus \(lineDirections.0):"
                detailSubtitle3.text = "Next Bus \(lineDirections.1):"
                detailSubtitle2.text = stop.nextTimeOnLine(line: lineName, direction: lineDirections.0)
                detailSubtitle4.text = stop.nextTimeOnLine(line: lineName, direction: lineDirections.1)
                
                if detailSubtitle4.text == "" {
                    detailSubtitle3.text = ""
                }
                
                if detailSubtitle2.text == "" {
                    detailSubtitle1.text = detailSubtitle3.text
                    detailSubtitle2.text = detailSubtitle4.text
                    detailSubtitle3.text = ""
                    detailSubtitle4.text = ""
                }
                
            } else {
                detailSubtitle2.text = stop.nextTimeOnLine(line: lineName, direction: "")
                
                detailSubtitle3.text = ""
                detailSubtitle4.text = ""
            }
           
        }
    }
    
    func growDetailView() {
        detailBigAnchor.isActive = true
        detailSmallAnchor.isActive = false
    }
    
    func shrinkDetailView() {
        detailSmallAnchor.isActive = true
        detailBigAnchor.isActive = false
    }
    

    @IBAction func detailCloseButtonClicked(_ sender: Any) {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.detailView.alpha = 0
            self.shortcutCollectionView.alpha = 1
        }) { (success) in
            self.detailView.isHidden = true
            self.shortcutCollectionView.isHidden = false
        }
        
    }
    
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

