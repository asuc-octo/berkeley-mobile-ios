//
//  DiningViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class DiningViewController: UIViewController {
    
    private var filterTableView: FilterTableView = FilterTableView<DiningLocation>(frame: .zero, filters: [])
    private var diningLocations: [DiningLocation] = []
    
    private var headerLabel: UILabel!
    private var diningCard: CardView!
    
    private var locationManager = CLLocationManager()
    private var location: CLLocation?
    
    let diningImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Dining")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        setupCardView()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        location = locationManager.location
        
        filterTableView.setSortFunc(newSortFunc: {dh1, dh2 in SortingFunctions.sortClose(loc1: dh1, loc2: dh2, location: self.location, locationManager: self.locationManager)})
        
        DataManager.shared.fetch(source: DiningHallDataSource.self) { diningLocations in
            self.diningLocations = diningLocations as? [DiningLocation] ?? []
            self.filterTableView.setData(data: diningLocations as! [DiningLocation])
            self.filterTableView.tableView.reloadData()
        }
        
        DataManager.shared.fetch(source: CafeDataSource.self) { cafeLocations in
            self.diningLocations.append(contentsOf: cafeLocations as? [DiningLocation] ?? [])
            self.filterTableView.setData(data: self.diningLocations as! [DiningLocation])
            self.filterTableView.tableView.reloadData()
        }
    }
}

extension DiningViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = manager.location
        self.filterTableView.sort()
        self.filterTableView.tableView.reloadData()
    }
}

extension DiningViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath) as? FilterTableViewCell {
            let diningHall: DiningLocation = self.filterTableView.filteredData[indexPath.row]
            cell.nameLabel.text = diningHall.name
            var distance = Double.nan
            if location != nil {
                distance = diningHall.getDistanceToUser(userLoc: location!)
            }
            if !distance.isNaN && distance < DiningHall.invalidDistance {
                cell.timeLabel.text = "\(distance) mi"
            }
            cell.recLabel.text = "Recommended"
            switch indexPath.row % 3 {
            case 0:
                cell.capBadge.text = "High"
            case 1:
                cell.capBadge.text = "Medium"
            default:
                cell.capBadge.text = "Low"
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
            
            if diningHall.image == nil {
                cell.cellImage.image = UIImage(named: "DoeGlade")
                DispatchQueue.global().async {
                    if diningHall.imageURL == nil {
                        return
                    }
                    guard let imageData = try? Data(contentsOf: diningHall.imageURL!) else { return }
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        diningHall.image = image
                        if tableView.visibleCells.contains(cell) {
                            cell.cellImage.image = image
                        }
                    }
                }
            } else {
                cell.cellImage.image = diningHall.image!
            }

            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DiningDetailViewController()
        vc.diningHall = self.filterTableView.filteredData[indexPath.row]
        self.present(vc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DiningViewController {
    // General card page
    func setupCardView() {
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let header = UILabel()
        header.text = "Find a place to dine"
        header.font = Font.bold(24)
        header.adjustsFontSizeToFitWidth = true
        header.textColor = Color.blackText
        card.addSubview(header)
        
        card.addSubview(diningImage)
        diningImage.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        diningImage.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        diningImage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        diningImage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: diningImage.rightAnchor, constant: 15).isActive = true
        header.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        setupTableView()
        card.addSubview(filterTableView)
        
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        filterTableView.topAnchor.constraint(equalTo: header.layoutMarginsGuide.bottomAnchor, constant: 16).isActive = true
        filterTableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        filterTableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        
        diningCard = card
        headerLabel = header
    }
    
    // Table of dining locations
    func setupTableView() {
        let filters = [Filter<DiningLocation>(label: "Nearby", filter: {dh in dh.getDistanceToUser(userLoc: self.location) < DiningLocation.nearbyDistance}),
            Filter<DiningLocation>(label: "Open", filter: {dh in dh.isOpen ?? false})]
        self.filterTableView = FilterTableView(frame: .zero, filters: filters)
        self.filterTableView.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.kCellIdentifier)
        self.filterTableView.tableView.dataSource = self
        self.filterTableView.tableView.delegate = self
    }
    
}
