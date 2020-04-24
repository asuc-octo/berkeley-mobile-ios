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
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
fileprivate let kViewMargin: CGFloat = 16

class LibraryDetailViewController: SearchDrawerViewController {

    var scrollView: UIScrollView!
    var library : Library!
    var contentHelper: UIView!
    var locationManager = CLLocationManager()
    var userCoords = CLLocationCoordinate2D(latitude: 0.0 , longitude: 0.0 )
    var distLabel = UILabel()
    var overviewCard = CardView()
    var hoursCard = CardView()
    var bookButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //location stuff
        locationManager.delegate = self
        
        view.layoutMargins = UIEdgeInsets(top: 3*kViewMargin, left: kViewMargin, bottom: kViewMargin, right: kViewMargin)
        setUpScrollView()
        setUpOverviewCard()
        setUpHoursCard()
        //setUpTrafficCard()
        setUpBookButton()
        
        view.layoutSubviews()
        scrollView.layoutSubviews()
        contentHelper.layoutSubviews()
        /* Set the bottom cutoff point for when view appears due to map search
         The "middle" position for the view will show everything in the overview card
         When collapsible open time card is added, change this to show that card as well. */
        middleCutoffPosition = scrollView.frame.minY + contentHelper.frame.minY + overviewCard.frame.maxY + 5
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
}

extension LibraryDetailViewController {
    
    func setUpOverviewCard() {
        overviewCard.isUserInteractionEnabled = true
        overviewCard.layoutMargins = kCardPadding
        contentHelper.addSubview(overviewCard)
        overviewCard.translatesAutoresizingMaskIntoConstraints = false
        overviewCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.font = Font.bold(24)
        nameLabel.text = library!.searchName
        overviewCard.addSubview(nameLabel)
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        nameLabel.adjustsFontSizeToFitWidth = true
        
        let libPic = UIImageView()
        if library?.image != nil {
            libPic.image = library?.image
        } else {
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: self.library!.imageURL!) else { return }
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    libPic.image = image
                    self.library.image = image
                }
            }
        }
        
        
        overviewCard.addSubview(libPic)
        libPic.translatesAutoresizingMaskIntoConstraints = false
        libPic.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.topAnchor).isActive = true
        libPic.rightAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.rightAnchor).isActive = true
        libPic.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.48).isActive = true
        libPic.contentMode = .scaleAspectFit
        libPic.isUserInteractionEnabled = true
        
        let addressIcon = UIImageView()
        addressIcon.image = UIImage(named: "Placemark")
        overviewCard.addSubview(addressIcon)
        addressIcon.translatesAutoresizingMaskIntoConstraints = false
        addressIcon.leftAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.leftAnchor).isActive = true
        addressIcon.bottomAnchor.constraint(equalTo: libPic.layoutMarginsGuide.bottomAnchor).isActive = true
        addressIcon.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
        addressIcon.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor).isActive = true
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
        overviewCard.addSubview(addressLabel)
        addressLabel.font = Font.light(12)
        addressLabel.numberOfLines = 0
        addressLabel.textColor = Color.blackText
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.bottomAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.bottomAnchor).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.rightAnchor, constant: 15).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: libPic.layoutMarginsGuide.leftAnchor, constant: -10).isActive = true
        addressLabel.topAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.topAnchor).isActive = true
        addressLabel.adjustsFontSizeToFitWidth = true
        
        let phoneIcon = UIImageView()
        phoneIcon.image = #imageLiteral(resourceName: "telephone")
        overviewCard.addSubview(phoneIcon)
        phoneIcon.translatesAutoresizingMaskIntoConstraints = false
        phoneIcon.leftAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.leftAnchor).isActive = true
        phoneIcon.topAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        phoneIcon.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
        phoneIcon.contentMode = .scaleAspectFit
        phoneIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        let phoneLabel = UILabel()
        phoneLabel.text = library!.phoneNumber
        overviewCard.addSubview(phoneLabel)
        phoneLabel.font = Font.light(12)
        phoneLabel.textColor = Color.blackText
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.topAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: phoneIcon.layoutMarginsGuide.rightAnchor, constant: 15).isActive = true
        phoneLabel.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.2).isActive = true
        phoneLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        phoneLabel.adjustsFontSizeToFitWidth = true
        
        //walking distance
        var distance = Double.nan
        let userLoc = CLLocation(latitude: userCoords.latitude, longitude: userCoords.longitude)
        distance = library.getDistanceToUser(userLoc: userLoc)
        if !distance.isNaN && distance < Library.invalidDistance {
            distLabel.text = "\(distance) miles away"
        }
        else {
            self.distLabel.text = ""
        }
            
        let distIcon = UIImageView()
        distIcon.image = #imageLiteral(resourceName: "Walk")
        overviewCard.addSubview(distIcon)
        distIcon.translatesAutoresizingMaskIntoConstraints = false
        distIcon.leftAnchor.constraint(equalTo: phoneLabel.layoutMarginsGuide.rightAnchor, constant: 15).isActive = true
        distIcon.topAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        distIcon.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.06).isActive = true
        distIcon.contentMode = .scaleAspectFit
        distIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
       
        overviewCard.addSubview(distLabel)
        distLabel.font = Font.light(12)
        distLabel.textColor = Color.blackText
        distLabel.translatesAutoresizingMaskIntoConstraints = false
        distLabel.topAnchor.constraint(equalTo: addressIcon.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        distLabel.leftAnchor.constraint(equalTo: distIcon.layoutMarginsGuide.rightAnchor, constant: 15).isActive = true
        distLabel.widthAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.widthAnchor, multiplier: 0.25).isActive = true
        distLabel.adjustsFontSizeToFitWidth = true
        distLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let faveButton = UIButton()
        faveButton.backgroundColor = .clear
        if library!.isFavorited {
            faveButton.setImage(#imageLiteral(resourceName: "favorited-icon"), for: .normal)
        } else {
            faveButton.setImage(#imageLiteral(resourceName: "not-favorited-icon"), for: .normal)
        }
        faveButton.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        faveButton.isUserInteractionEnabled = true
        overviewCard.addSubview(faveButton)
        faveButton.translatesAutoresizingMaskIntoConstraints = false
        faveButton.topAnchor.constraint(equalTo: libPic.layoutMarginsGuide.bottomAnchor).isActive = true
        faveButton.rightAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.rightAnchor).isActive = true
        faveButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        faveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        faveButton.imageView?.contentMode = .scaleAspectFit
        faveButton.imageView?.isUserInteractionEnabled = true
        
        overviewCard.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor).isActive = true
        overviewCard.bottomAnchor.constraint(equalTo: faveButton.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
    }
    
    func setUpHoursCard() {
        hoursCard.isUserInteractionEnabled = true
        hoursCard.layoutMargins = kCardPadding
        contentHelper.addSubview(hoursCard)
        hoursCard.translatesAutoresizingMaskIntoConstraints = false
        hoursCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        hoursCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        hoursCard.topAnchor.constraint(equalTo: overviewCard.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        
        let clockIcon = UIImageView()
        clockIcon.image = #imageLiteral(resourceName: "Clock")
        hoursCard.addSubview(clockIcon)
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        clockIcon.leftAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.leftAnchor).isActive = true
        clockIcon.topAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.topAnchor).isActive = true
        clockIcon.contentMode = .scaleAspectFit
        clockIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let openLabel = UILabel()
        openLabel.layer.masksToBounds = true
        openLabel.layer.cornerRadius = 10
        openLabel.font = Font.semibold(14)
        openLabel.backgroundColor = Color.openTag
        openLabel.textColor = .white
        openLabel.text = library!.isOpen! ? "  Open  " : "  Closed  "
        hoursCard.addSubview(openLabel)
        openLabel.translatesAutoresizingMaskIntoConstraints = false
        openLabel.topAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.topAnchor).isActive = true
        openLabel.leftAnchor.constraint(equalTo: clockIcon.layoutMarginsGuide.rightAnchor, constant: 20).isActive = true
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let currentHours = UILabel()
        currentHours.font = Font.bold(14)
        let date = Date()
        if let intervals = library!.weeklyHours?.hoursForWeekday(.weekday(date)) {
            for interval in intervals {
                if interval.contains(date) {
                    currentHours.text = formatter.string(from: interval.start, to: interval.end)
                    break
                }
            }
        }
        hoursCard.addSubview(currentHours)
        currentHours.translatesAutoresizingMaskIntoConstraints = false
        currentHours.topAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.topAnchor).isActive = true
        currentHours.leftAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.rightAnchor, constant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.font = Font.light(12)
        nameLabel.numberOfLines = 7
        hoursCard.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.bottomAnchor, constant: 12).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: openLabel.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.widthAnchor, multiplier: 0.45).isActive = true

        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        nameLabel.text = ""
        for dayName in days {
            nameLabel.text = nameLabel.text! + (dayName == "Sunday" ? "" : "\n") + dayName
        }
        
        let timeLabel = UILabel()
        timeLabel.font = Font.light(12)
        timeLabel.numberOfLines = 7
        hoursCard.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.topAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.rightAnchor, constant: 5).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.widthAnchor, multiplier: 0.5).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: nameLabel.layoutMarginsGuide.bottomAnchor).isActive = true
        timeLabel.text = ""
        for i in 0...6 {
            let hours = library!.weeklyHours?.hoursForWeekday(DayOfWeek(rawValue: i)!)
                if hours == [] {
                    timeLabel.text = timeLabel.text! + (i == 0 ? "" : "\n") + "Closed"
                } else {
                    timeLabel.text = timeLabel.text! + (i == 0 ? "" : "\n") + formatter.string(from: hours![0].start, to: hours![0].end)
                    if hours![0].start == hours![0].end {
                        timeLabel.text! += " - "
                    }
                }
            
        }
        
        hoursCard.bottomAnchor.constraint(equalTo: timeLabel.layoutMarginsGuide.bottomAnchor, constant: 20).isActive = true
    }
    
    func setUpTrafficCard() {
        let overviewCard = CardView()
        overviewCard.layoutMargins = kCardPadding
        scrollView.addSubview(overviewCard)
        overviewCard.translatesAutoresizingMaskIntoConstraints = false
        overviewCard.topAnchor.constraint(equalTo: contentHelper.layoutMarginsGuide.topAnchor, constant: 400).isActive = true
        overviewCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    
    func setUpBookButton() {
        bookButton.isUserInteractionEnabled = true
        bookButton.layoutMargins = kCardPadding
        contentHelper.addSubview(bookButton)
        bookButton.backgroundColor =  Color.eventAcademic
        bookButton.layer.cornerRadius = 10
        bookButton.layer.shadowRadius = 5
        bookButton.layer.shadowOpacity = 0.25
        bookButton.layer.shadowOffset = .zero
        bookButton.layer.shadowColor = UIColor.black.cgColor
        bookButton.layer.shadowPath = UIBezierPath(rect: bookButton.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        bookButton.topAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.bottomAnchor, constant: 10).isActive = true
        bookButton.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        bookButton.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        bookButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bookButton.setTitle("Book a Study Room >", for: .normal)
        bookButton.titleLabel!.font = Font.semibold(14)
        bookButton.titleLabel!.textColor = .white
        
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
        contentHelper.isUserInteractionEnabled = true
        scrollView.addSubview(contentHelper)
    }
}

extension LibraryDetailViewController {
    
    @objc func toggleFave(sender: UIButton) {
        print("toggle fave funtion")
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
            //reloads overviewCard with distance marker
            var distance = Double.nan
            let userLoc = CLLocation(latitude: self.userCoords.latitude, longitude: self.userCoords.longitude)
            distance = self.library.getDistanceToUser(userLoc: userLoc)
            if !distance.isNaN && distance < Library.invalidDistance {
                self.distLabel.text = "\(distance) miles away"
            }
            else {
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
