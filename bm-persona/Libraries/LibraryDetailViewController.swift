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
    var openTimesCard: OpenTimesCardView?
    var bookButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //location stuff
        locationManager.delegate = self
        
        setUpScrollView()
        setUpOverviewCard()
        setUpOpenTimesCard()
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
        middleCutoffPosition = (openTimesCard?.frame.maxY ?? overviewCard.frame.maxY) + 8
    }
}

extension LibraryDetailViewController {
    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: library, excludedElements: [.openTimes, .occupancy], userLocation: locationManager.location)
        scrollView.addSubview(overviewCard)
        overviewCard.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        overviewCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setUpOpenTimesCard() {
        guard library.weeklyHours != nil else { return }
        openTimesCard = OpenTimesCardView(item: library, openedAction: {
            self.delegate.moveDrawer(to: .full, duration: 0.2)
        })
        let openTimesCard = self.openTimesCard!
        scrollView.addSubview(openTimesCard)
        openTimesCard.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        openTimesCard.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        openTimesCard.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
    }
    
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
        bookButton.topAnchor.constraint(equalTo: openTimesCard?.bottomAnchor ?? overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
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
