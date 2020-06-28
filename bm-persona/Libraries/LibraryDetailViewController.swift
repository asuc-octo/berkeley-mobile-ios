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
    var locationManager = CLLocationManager()
    var userCoords = CLLocationCoordinate2D(latitude: 0.0 , longitude: 0.0 )
    var distLabel = UILabel()
    var overviewCard: OverviewCardView!
    var hoursCard = CardView()
    var bookButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //location stuff
        locationManager.delegate = self
        
        setUpScrollView()
        setUpOverviewCard()
        setUpHoursCard()
        //setUpTrafficCard()
        setUpBookButton()
        
        // in order to set the cutoff correctly
        view.layoutSubviews()
        scrollView.layoutSubviews()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        /* Set the bottom cutoff point for when the drawer appears
        The "middle" position for the view will show everything in the overview card
        When collapsible open time card is added, change this to show that card as well. */
        middleCutoffPosition = overviewCard.frame.maxY + 8
    }
}

extension LibraryDetailViewController {
    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: library, userLocation: locationManager.location)
        view.addSubview(overviewCard)
        overviewCard.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        overviewCard.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.layoutSubviews()
    }
    
    func setUpHoursCard() {
        hoursCard.isUserInteractionEnabled = true
        hoursCard.layoutMargins = kCardPadding
        scrollView.addSubview(hoursCard)
        hoursCard.translatesAutoresizingMaskIntoConstraints = false
        hoursCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        hoursCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        hoursCard.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        
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
    
//    func setUpTrafficCard() {
//        let overviewCard = CardView()
//        overviewCard.layoutMargins = kCardPadding
//        scrollView.addSubview(overviewCard)
//        overviewCard.translatesAutoresizingMaskIntoConstraints = false
//        overviewCard.topAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.topAnchor, constant: 400).isActive = true
//        overviewCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
//        overviewCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
//        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
//    }
//
    
    func setUpBookButton() {
        bookButton.isUserInteractionEnabled = true
        bookButton.layoutMargins = kCardPadding
        scrollView.addSubview(bookButton)
        bookButton.backgroundColor =  Color.eventAcademic
        bookButton.layer.cornerRadius = 10
        bookButton.layer.shadowRadius = 5
        bookButton.layer.shadowOpacity = 0.25
        bookButton.layer.shadowOffset = .zero
        bookButton.layer.shadowColor = UIColor.black.cgColor
        bookButton.layer.shadowPath = UIBezierPath(rect: bookButton.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        bookButton.topAnchor.constraint(equalTo: hoursCard.layoutMarginsGuide.bottomAnchor, constant: kViewMargin).isActive = true
        bookButton.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        bookButton.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        bookButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bookButton.setTitle("Book a Study Room >", for: .normal)
        bookButton.titleLabel!.font = Font.semibold(14)
        bookButton.titleLabel!.textColor = .white
        
    }
    
    func setUpScrollView() {
        scrollView = UIScrollView(frame: .zero)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: barView.topAnchor, constant: kViewMargin).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
}
    
extension LibraryDetailViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation
        DispatchQueue.main.async {
            self.overviewCard.updateLocation(userLocation: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
