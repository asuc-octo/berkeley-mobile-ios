//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let kHeaderFont: UIFont = Font.bold(24)
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class LibraryDetailViewController: UIViewController {

    var scrollView: UIScrollView!
    var libraries: [Library] = []
    var library : Library?
    var contentHelper: UIView!
    var locationManager = CLLocationManager()
    var userCoords = CLLocationCoordinate2D(latitude: 0.0 , longitude: 0.0 )
    var distLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        //location stuff
        locationManager.delegate = self
        
        // get library data
        DataManager.shared.fetch(source: LibraryDataSource.self) { libraries in
            self.libraries = libraries as? [Library] ?? []
            self.library = libraries[4] as? Library
            }
        
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setUpScrollView()
        setUpOverviewCard()
        setUpHoursCard()
        //setUpTrafficCard()
        setUpBookButton()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
}

extension LibraryDetailViewController {
    
    func setUpOverviewCard() {
        let card = CardView()
        card.isUserInteractionEnabled = true
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.font = Font.semibold(20)
        nameLabel.text = library!.searchName
        card.addSubview(nameLabel)
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: card.layoutMarginsGuide.heightAnchor, multiplier: 0.5).isActive = true
        nameLabel.adjustsFontSizeToFitWidth = true
        
        let addressIcon = UIImageView()
        addressIcon.image = #imageLiteral(resourceName: "Walk")
        card.addSubview(addressIcon)
        addressIcon.translatesAutoresizingMaskIntoConstraints = false
        addressIcon.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        addressIcon.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        addressIcon.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
        addressIcon.contentMode = .scaleAspectFit
        
        
        let addressLabel = UILabel()
        if let longAddress = library!.campusLocation {
            if let ind = longAddress.range(of: "Berkeley")?.upperBound {
                let newAdress = longAddress[..<ind]
                addressLabel.text = String(newAdress)
            } else {
                addressLabel.text = longAddress
            }
        }
        card.addSubview(addressLabel)
        addressLabel.font = Font.thin(12)
        addressLabel.numberOfLines = 2
        addressLabel.textColor = UIColor.black
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.rightAnchor, constant: 8).isActive = true
        //addressLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor, constant: -160).isActive = true
        addressLabel.adjustsFontSizeToFitWidth = true
        
        
        let phoneLabel = UILabel()
        phoneLabel.text = library!.phoneNumber
        card.addSubview(phoneLabel)
        phoneLabel.font = Font.thin(12)
        phoneLabel.textColor = UIColor.black
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.topAnchor.constraint(equalTo: addressLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        phoneLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        phoneLabel.adjustsFontSizeToFitWidth = true
        
        //walking distance
        if let libLat = library!.latitude, let libLong = library!.longitude {
            let dist = calcDistance(lib_Lat: libLat, lib_Long: libLong)
            distLabel.text = String(format: "%.1f", dist) + " miles away"
            
        } else {
            distLabel.text = "distance not availible"
        }
        card.addSubview(distLabel)
        distLabel.font = Font.thin(12)
        distLabel.textColor = UIColor.black
        distLabel.translatesAutoresizingMaskIntoConstraints = false
        distLabel.topAnchor.constraint(equalTo: phoneLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        distLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        distLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        distLabel.adjustsFontSizeToFitWidth = true
        
        let libPic = UIImageView()
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: self.library!.imageURL!) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                libPic.image = image
            }
        }
        card.addSubview(libPic)
        libPic.translatesAutoresizingMaskIntoConstraints = false
        libPic.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor, constant: 5).isActive = true
        libPic.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        libPic.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.48).isActive = true
        libPic.heightAnchor.constraint(equalTo: card.layoutMarginsGuide.heightAnchor, multiplier: 0.66).isActive = true
        libPic.contentMode = .scaleAspectFit
        
        let faveButton = UIButton()
        faveButton.backgroundColor = .clear
        if library!.isFavorited {
            faveButton.setImage(#imageLiteral(resourceName: "favorited-icon"), for: .normal)
        } else {
            faveButton.setImage(#imageLiteral(resourceName: "not-favorited-icon"), for: .normal)
        }
        faveButton.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        faveButton.isUserInteractionEnabled = true
        card.addSubview(faveButton)
        faveButton.translatesAutoresizingMaskIntoConstraints = false
        faveButton.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        faveButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        faveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        faveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setUpHoursCard() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor, constant: 210).isActive = true
        card.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        let openLabel = UILabel()
        openLabel.layer.masksToBounds = true
        openLabel.layer.cornerRadius = 10
        openLabel.font = Font.semibold(14)
        openLabel.backgroundColor = .systemBlue
        openLabel.textColor = .white
        openLabel.text = library!.isOpen ? "  Open  " : "  Closed  "
        card.addSubview(openLabel)
        openLabel.translatesAutoresizingMaskIntoConstraints = false
        openLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        openLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor, constant: 20).isActive = true
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let currentHours = UILabel()
        currentHours.font = Font.bold(14)
        let date = Date()
        if let interval = library!.weeklyHours[date.weekday()] {
            if interval.contains(date) {
                currentHours.text = formatter.string(from: interval.start, to: interval.end)
            }
        }
        card.addSubview(currentHours)
        currentHours.translatesAutoresizingMaskIntoConstraints = false
        currentHours.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        currentHours.leftAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.rightAnchor, constant: 40).isActive = true
        
        
        let nameLabel = UILabel()
        nameLabel.font = Font.thin(12)
        nameLabel.numberOfLines = 7
        card.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.bottomAnchor, constant: 12).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor, constant: 25).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        nameLabel.text = ""
        for dayName in days {
            nameLabel.text = nameLabel.text! + (dayName == "Sunday" ? "" : "\n") + dayName
        }
        
        let timeLabel = UILabel()
        timeLabel.font = Font.thin(12)
        timeLabel.numberOfLines = 7
        card.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.topAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.rightAnchor, constant: 5).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        timeLabel.text = ""
        for i in 0...6 {
            if let timeInverval = library!.weeklyHours[i] {
                if timeInverval.start == timeInverval.end {
                    timeLabel.text = timeLabel.text! + (i == 0 ? "" : "\n") + "Closed"
                } else {
                    timeLabel.text = timeLabel.text! + (i == 0 ? "" : "\n") + formatter.string(from: timeInverval.start, to: timeInverval.end)
                }
            }
        }
        
        
        let dataLabel = UILabel()
        dataLabel.font = Font.thin(12)
        dataLabel.numberOfLines = 7
        card.addSubview(dataLabel)
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        dataLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        dataLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.3).isActive = true
    }
    
    func setUpTrafficCard() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor, constant: 400).isActive = true
        card.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    
    func setUpBookButton() {
        let button = UIButton()
        button.layoutMargins = kCardPadding
        scrollView.addSubview(button)
        button.backgroundColor = .systemBlue
        // WHY WONT THIS WORK
        button.layer.cornerRadius = 10
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowPath = UIBezierPath(rect: button.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor, constant: 400).isActive = true
        //change the top anchor constant to 610 when including the card with usage information
        button.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle("Book a Study Room >", for: .normal)
        button.titleLabel!.font = Font.semibold(14)
        button.titleLabel!.textColor = .white
        
    }
    
    func setUpScrollView() {
        scrollView = UIScrollView(frame: .zero)
        scrollView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        contentHelper = UIView()
        scrollView.addSubview(contentHelper)
    }
}

extension LibraryDetailViewController {
    
    @objc func toggleFave(sender: UIButton) {
               if library!.isFavorited {
                sender.setImage(#imageLiteral(resourceName: "not-favorited-icon"), for: .normal)
                library!.isFavorited = false
               } else {
                sender.setImage(#imageLiteral(resourceName: "favorited-icon"), for: .normal)
                library!.isFavorited = true
        }
    }
    
}
    
    extension  LibraryDetailViewController : CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation : CLLocation = locations[0] as CLLocation
            userCoords.latitude = userLocation.coordinate.latitude
            userCoords.longitude = userLocation.coordinate.longitude
            DispatchQueue.main.async {
                //reloads card with distance marker
                if self.library != nil, let libLat = self.library!.latitude, let libLong = self.library!.longitude {
                    let dist = self.calcDistance(lib_Lat: libLat, lib_Long: libLong)
                    self.distLabel.text = String(format: "%.1f", dist) + " miles away"
                    
                } else {
                    self.distLabel.text = "distance not availible"
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            // might be that user didn't enable location service on the device
            // or there might be no GPS signal inside a building
            // might be a good idea to show an alert to user to ask them to walk to a place with GPS signal
            print(error)
        }
        
        func calcDistance(lib_Lat : Double, lib_Long: Double) -> Double {
            var userLat = userCoords.latitude
            var userLong = userCoords.longitude
            let libLat = lib_Lat / 57.29577951
            let libLong = lib_Long / 57.29577951
            userLat = userLat / 57.29577951
            userLong = userLong / 57.29577951
            let dLat = libLat-userLat
            let dLong = libLong - userLong
            let intermediate = pow(sin(dLat / 2),2 ) + cos(libLat) * cos(userLat) * pow(sin(dLong/2),2)
            return 2 * asin(sqrt(intermediate)) * 6371
        }
        
    
}
