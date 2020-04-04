//
//  DiningDetailViewController.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let kHeaderFont: UIFont = Font.bold(24)
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class DiningDetailViewController: UIViewController {
    
    var diningHall: DiningHall?
    var contentHelper: UIView!
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var distLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        locationManager.delegate = self
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setUpOverviewCard()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
}

extension DiningDetailViewController {
    
    func setUpOverviewCard() {
        contentHelper = UIView()
        view.addSubview(contentHelper)
        
        let card = CardView()
        card.isUserInteractionEnabled = true
        card.layoutMargins = kCardPadding
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.font = Font.semibold(20)
        nameLabel.text = diningHall!.searchName
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
        addressIcon.image = UIImage(named: "Placemark")
        card.addSubview(addressIcon)
        addressIcon.translatesAutoresizingMaskIntoConstraints = false
        addressIcon.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        addressIcon.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        addressIcon.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
        addressIcon.contentMode = .scaleAspectFit
        
        
        let addressLabel = UILabel()
        if let longAddress = diningHall!.campusLocation {
            if let ind = longAddress.range(of: "Berkeley")?.upperBound {
                let newAdress = longAddress[..<ind]
                addressLabel.text = String(newAdress)
            } else {
                addressLabel.text = longAddress
            }
        }
        card.addSubview(addressLabel)
        addressLabel.font = Font.light(12)
        addressLabel.numberOfLines = 2
        addressLabel.textColor = UIColor.black
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.rightAnchor, constant: 8).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor, constant: -160).isActive = true
        addressLabel.adjustsFontSizeToFitWidth = true
        
        let phoneIcon = UIImageView()
        phoneIcon.image = UIImage(named: "Placemark")
        card.addSubview(phoneIcon)
        phoneIcon.translatesAutoresizingMaskIntoConstraints = false
        phoneIcon.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        phoneIcon.topAnchor.constraint(equalTo: addressLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        phoneIcon.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
        phoneIcon.contentMode = .scaleAspectFit
        
        let phoneLabel = UILabel()
        phoneLabel.text = diningHall!.phoneNumber
        card.addSubview(phoneLabel)
        phoneLabel.font = Font.light(12)
        phoneLabel.textColor = UIColor.black
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.topAnchor.constraint(equalTo: addressLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: phoneIcon.layoutMarginsGuide.rightAnchor, constant:  8).isActive = true
        phoneLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.25).isActive = true
        phoneLabel.adjustsFontSizeToFitWidth = true
        
//        let distIcon = UIImageView()
//        distIcon.image = UIImage(named: "Walking")
//        card.addSubview(distIcon)
//        distIcon.translatesAutoresizingMaskIntoConstraints = false
//        distIcon.leftAnchor.constraint(equalTo: phoneLabel.layoutMarginsGuide.rightAnchor, constant:  20).isActive = true
//        distIcon.topAnchor.constraint(equalTo: addressLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
//        distIcon.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
//        distIcon.contentMode = .scaleAspectFit
//        
//        if self.diningHall != nil && location != nil {
//            let dist = self.diningHall!.getDistanceToUser(userLoc: location)
//            self.distLabel.text = String(dist) + " mi"
//        } else {
//            self.distLabel.text = ""
//        }
//        card.addSubview(distLabel)
//        distLabel.font = Font.thin(12)
//        distLabel.textColor = UIColor.black
//        distLabel.translatesAutoresizingMaskIntoConstraints = false
//        distLabel.topAnchor.constraint(equalTo: addressLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
//        distLabel.leftAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.rightAnchor, constant: 8).isActive = true
//        distLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.25).isActive = true
//        distLabel.adjustsFontSizeToFitWidth = true
        
        let diningPic = UIImageView()
        if diningHall!.image != nil {
            diningPic.image = diningHall!.image
        } else {
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: self.diningHall!.imageURL!) else { return }
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.diningHall!.image = image
                    diningPic.image = image
                }
            }
        }
        card.addSubview(diningPic)
        diningPic.translatesAutoresizingMaskIntoConstraints = false
        diningPic.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor, constant: 5).isActive = true
        diningPic.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        diningPic.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.48).isActive = true
        diningPic.heightAnchor.constraint(equalTo: card.layoutMarginsGuide.heightAnchor, multiplier: 0.66).isActive = true
        diningPic.contentMode = .scaleAspectFit
        
//        let faveButton = UIButton()
//        faveButton.backgroundColor = .clear
//        if diningHall!.isFavorited {
//            faveButton.setImage(#imageLiteral(resourceName: "favorited-icon"), for: .normal)
//        } else {
//            faveButton.setImage(#imageLiteral(resourceName: "not-favorited-icon"), for: .normal)
//        }
//        faveButton.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
//        faveButton.isUserInteractionEnabled = true
//        card.addSubview(faveButton)
//        faveButton.translatesAutoresizingMaskIntoConstraints = false
//        faveButton.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
//        faveButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
//        faveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        faveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
//    func setUpHoursCard() {
//        let card = CardView()
//        card.layoutMargins = kCardPadding
//        scrollView.addSubview(card)
//        card.translatesAutoresizingMaskIntoConstraints = false
//        card.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor, constant: 210).isActive = true
//        card.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
//        card.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
//        card.heightAnchor.constraint(equalToConstant: 180).isActive = true
//
//        let openLabel = UILabel()
//        openLabel.layer.masksToBounds = true
//        openLabel.layer.cornerRadius = 10
//        openLabel.font = Font.semibold(14)
//        openLabel.backgroundColor = .systemBlue
//        openLabel.textColor = .white
//        openLabel.text = library!.isOpen ? "  Open  " : "  Closed  "
//        card.addSubview(openLabel)
//        openLabel.translatesAutoresizingMaskIntoConstraints = false
//        openLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
//        openLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor, constant: 20).isActive = true
//
//        let formatter = DateIntervalFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        let currentHours = UILabel()
//        currentHours.font = Font.bold(14)
//        let date = Date()
//        if let interval = library!.weeklyHours[date.weekday()] {
//            if interval.contains(date) {
//                currentHours.text = formatter.string(from: interval.start, to: interval.end)
//            }
//        }
//        card.addSubview(currentHours)
//        currentHours.translatesAutoresizingMaskIntoConstraints = false
//        currentHours.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
//        currentHours.leftAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.rightAnchor, constant: 40).isActive = true
//
//
//        let nameLabel = UILabel()
//        nameLabel.font = Font.thin(12)
//        nameLabel.numberOfLines = 7
//        card.addSubview(nameLabel)
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel.topAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.bottomAnchor, constant: 12).isActive = true
//        nameLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor, constant: 25).isActive = true
//        nameLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
//        nameLabel.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
//        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
//        nameLabel.text = ""
//        for dayName in days {
//            nameLabel.text = nameLabel.text! + (dayName == "Sunday" ? "" : "\n") + dayName
//        }
//
//        let timeLabel = UILabel()
//        timeLabel.font = Font.thin(12)
//        timeLabel.numberOfLines = 7
//        card.addSubview(timeLabel)
//        timeLabel.translatesAutoresizingMaskIntoConstraints = false
//        timeLabel.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.topAnchor).isActive = true
//        timeLabel.leftAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.rightAnchor, constant: 5).isActive = true
//        timeLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
//        timeLabel.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
//        timeLabel.text = ""
//        for i in 0...6 {
//            if let timeInverval = library!.weeklyHours[i] {
//                if timeInverval.start == timeInverval.end {
//                    timeLabel.text = timeLabel.text! + (i == 0 ? "" : "\n") + "Closed"
//                } else {
//                    timeLabel.text = timeLabel.text! + (i == 0 ? "" : "\n") + formatter.string(from: timeInverval.start, to: timeInverval.end)
//                }
//            }
//        }
//
//
//        let dataLabel = UILabel()
//        dataLabel.font = Font.thin(12)
//        dataLabel.numberOfLines = 7
//        card.addSubview(dataLabel)
//        dataLabel.translatesAutoresizingMaskIntoConstraints = false
//        dataLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
//        dataLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
//        dataLabel.widthAnchor.constraint(equalTo: card.layoutMarginsGuide.widthAnchor, multiplier: 0.3).isActive = true
//    }
    
}

extension DiningDetailViewController {
    
    @objc func toggleFave(sender: UIButton) {
        if diningHall!.isFavorited {
            sender.setImage(#imageLiteral(resourceName: "not-favorited-icon"), for: .normal)
            diningHall!.isFavorited = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "favorited-icon"), for: .normal)
            diningHall!.isFavorited = true
        }
    }
    
}

extension  DiningDetailViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation
        DispatchQueue.main.async {
            //reloads card with distance marker
            if self.diningHall != nil {
                let dist = self.diningHall!.getDistanceToUser(userLoc: userLocation)
                self.distLabel.text = String(dist) + " mi"
                self.location = userLocation
            } else {
                self.distLabel.text = ""
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // might be that user didn't enable location service on the device
        // or there might be no GPS signal inside a building
        // might be a good idea to show an alert to user to ask them to walk to a place with GPS signal
        print(error)
    }
    
}
