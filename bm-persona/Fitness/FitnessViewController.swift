//
//  FitnessViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/21/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

fileprivate let kHeaderFont: UIFont = Font.bold(24)
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16
fileprivate let kTodayClassesHeight: CGFloat = 300

class FitnessViewController: UIViewController, CLLocationManagerDelegate {
    
    private var scrollView: UIScrollView!
    private var content: UIView!
    private var filterTableView = FilterTableView<Gym>(frame: .zero, filters: [])
    
    private var upcomingCard: CardView!
    private var todayCard: CardView!
    private var gymCard: CardView!
    
    private var bClassesExpanded = false
    
    private var gymsTable: UITableView!
    private var classesCollection: CardCollectionView!
    
    private var gyms: [Gym] = []
    private var locationManager = CLLocationManager()
    private var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        setupScrollView()
        setupUpcomingClasses()
        setupTodayClasses()
        setupGyms()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        location = locationManager.location
        filterTableView.setSortFunc(newSortFunc: {gym1, gym2 in SortingFunctions.sortClose(loc1: gym1, loc2: gym2, location: self.location, locationManager: self.locationManager)})
        
        DataManager.shared.fetch(source: GymDataSource.self) { gyms in
            self.gyms = gyms as? [Gym] ?? []
            self.filterTableView.setData(data: gyms as! [Gym])
            self.filterTableView.tableView.reloadData()
        }
    }
    
    @objc func willExpandClasses() {
        UIView.animate(withDuration: 0.2) {
            if !self.bClassesExpanded {
                self.todayCard.heightConstraint?.constant = self.view.frame.height
                self.todayCard.heightConstraint?.constant -=  self.view.layoutMargins.top + self.view.layoutMargins.bottom
            } else {
                self.todayCard.heightConstraint?.constant = kTodayClassesHeight
            }
            self.bClassesExpanded = !self.bClassesExpanded
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.todayCard.frame.minY)
            self.scrollView.contentOffset.y -= self.view.layoutMargins.top
            self.view.layoutIfNeeded()
            self.viewDidLayoutSubviews()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = manager.location
        self.filterTableView.sort()
        self.filterTableView.tableView.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegate

// Dummy Data
extension FitnessViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionView.kCellIdentifier, for: indexPath)
        if let card = cell as? CardCollectionViewCell {
            card.title.text = "Mat Pilates"
            card.subtitle.text = "Nov 10 / 1:00 PM"
            card.badge.text = "Core"
            card.badge.backgroundColor = .orange
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate

// Dummy Data
extension FitnessViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryTableViewCell.kCellIdentifier, for: indexPath) as? LibraryTableViewCell {
            let gym: Gym = self.filterTableView.filteredData[indexPath.row]
            cell.nameLabel.text = gym.name
            var distance = Double.nan
            if location != nil {
                distance = gym.getDistanceToUser(userLoc: location!)
            }
            if !distance.isNaN && distance < Gym.invalidDistance {
                cell.timeLabel.text = "\(distance) mi"
            }
            cell.recLabel.text = "Recommended"
            cell.selectionStyle = .none
            switch indexPath.row % 3 {
            case 0:
                cell.capBadge.text = "High"
            case 1:
                cell.capBadge.text = "Medium"
            default:
                cell.capBadge.text = "Low"
            }
            
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: gym.imageURL!) else { return }
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.cellImage.image = image
                }
            }
            switch cell.capBadge.text!.lowercased() {
            case "high":
                cell.capBadge.backgroundColor = Color.highCapacityTag
            case "medium":
                cell.capBadge.backgroundColor = Color.medCapacityTag
            case "low":
                cell.capBadge.backgroundColor = Color.lowCapacityTag
            default:
                cell.capBadge.backgroundColor = .clear
            }

            return cell
        }
        return UITableViewCell()
    }
    
}

// MARK: - View

extension FitnessViewController {
    
    // ScrollView
    func setupScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setConstraintsToView(top: view, bottom: view, left: view, right: view)
        
        content = UIView()
        scrollView.addSubview(content)
        content.layoutMargins = view.layoutMargins
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = gymCard.frame.maxY + view.layoutMargins.bottom
    }
    
    // Upcoming Classes
    func setupUpcomingClasses() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: content.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let contentView = UIView()
        contentView.layer.masksToBounds = true
        card.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setConstraintsToView(top: card, bottom: card, left: card, right: card)
        
        let headerLabel = UILabel()
        headerLabel.font = kHeaderFont
        headerLabel.text = "Upcoming Classes"
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let collectionView = CardCollectionView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: card.layoutMargins.left, bottom: 0, right: card.layoutMargins.right)
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: kViewMargin).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: CardCollectionViewCell.kCardSize.height).isActive = true
        collectionView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        
        collectionView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        upcomingCard = card
        classesCollection = collectionView
    }
    
    // Upcoming Classes
    func setupTodayClasses() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: kTodayClassesHeight).isActive = true
        
        let headerLabel = UILabel()
        headerLabel.font = kHeaderFont
        headerLabel.text = "Today's Classes"
        card.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        
        let scheduleButton = UIButton()
        scheduleButton.setTitle("See Full Schedule >", for: .normal)
        scheduleButton.titleLabel?.font = Font.thin(12)
        scheduleButton.setTitleColor(Color.primaryText, for: .normal)
        // TODO: Set color
        scheduleButton.setTitleColor(.black, for: .highlighted)
        scheduleButton.addTarget(self, action: #selector(willExpandClasses), for: .touchUpInside)
        card.addSubview(scheduleButton)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor).isActive = true
        scheduleButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        todayCard = card
    }
    
    // Gyms
    func setupGyms() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: todayCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor).isActive = true
        
        gymCard = card
        setupFilterTableView()
        scrollView.addSubview(filterTableView)
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        filterTableView.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        filterTableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        filterTableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -50).isActive = true
    }
    
    func setupFilterTableView() {
        let filters = [
            Filter<Gym>(label: "Nearby", filter: {gym in gym.getDistanceToUser(userLoc: self.location) < Gym.nearbyDistance}),
            Filter<Gym>(label: "Open", filter: {gym in gym.isOpen}),
        ]
        filterTableView = FilterTableView(frame: .zero, filters: filters)
        self.filterTableView.tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: LibraryTableViewCell.kCellIdentifier)
        self.filterTableView.tableView.dataSource = self
    }
    
}
