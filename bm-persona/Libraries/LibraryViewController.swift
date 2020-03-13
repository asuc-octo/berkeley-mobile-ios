//
//  LibraryViewController.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    private static let nearbyDistance: Double = 10
    private static let invalidDistance: Double = 100
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var safeArea: UILayoutGuide!
    let cellSpacingHeight: CGFloat = 14
    var libraries: [Library] = []
    var filteredLibraries: [Library] = []
    var filter: FilterView!
    var filters: [Filter<Library>] = []
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var sortFunc: ((Library, Library) -> Bool)?
    
    let bookImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Book")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let filterImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Filter")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: LibraryTableViewCell.kCellIdentifier)
        self.tableView.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        location = locationManager.location
        if sortFunc == nil {
            sortFunc = {lib1, lib2 in SortingFunctions.sortClose(loc1: lib1, loc2: lib2, location: self.location, locationManager: self.locationManager)}
        }
        DataManager.shared.fetch(source: LibraryDataSource.self) { libraries in
            self.libraries = libraries as? [Library] ?? []
            self.filteredLibraries = self.libraries
            self.filteredLibraries.sort(by: self.sortFunc!)
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = manager.location
        self.filteredLibraries.sort(by: self.sortFunc!)
        self.tableView.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        //removes separator lines
        safeArea = view.layoutMarginsGuide
        setupTableView()
    }
    
    func setupTableView() {
        //general setup and constraints
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let studyLabel = UILabel()
        studyLabel.textAlignment = .center
        studyLabel.text = "Find your study spot"
        studyLabel.font = UIFont.boldSystemFont(ofSize: 30)
        studyLabel.adjustsFontSizeToFitWidth = true
        studyLabel.textColor = .black
        studyLabel.textColor = Color.blackText
        card.addSubview(studyLabel)
        
        card.addSubview(bookImage)
        bookImage.centerYAnchor.constraint(equalTo: studyLabel.centerYAnchor).isActive = true
        bookImage.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor, constant: 5).isActive = true
        bookImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        bookImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        card.addSubview(filterImage)
        filterImage.centerYAnchor.constraint(equalTo: studyLabel.centerYAnchor).isActive = true
        filterImage.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive
            = true
        filterImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        filterImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        studyLabel.translatesAutoresizingMaskIntoConstraints = false
        studyLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        studyLabel.leftAnchor.constraint(equalTo: bookImage.rightAnchor, constant: 16).isActive = true
        studyLabel.rightAnchor.constraint(equalTo: filterImage.leftAnchor, constant: -25).isActive = true
        studyLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        
        filters = [
            Filter(label: "Nearby", filter: {lib in
                lib.getDistanceToUser(userLoc: self.location) < LibraryViewController.nearbyDistance}),
            Filter(label: "Open", filter: {lib in lib.isOpen}),
        ]
        filter = FilterView(frame: .zero)
        card.addSubview(filter)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        filter.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        filter.topAnchor.constraint(equalTo: studyLabel.layoutMarginsGuide.bottomAnchor, constant: 30).isActive = true
        filter.heightAnchor.constraint(equalToConstant: FilterViewCell.kCellSize.height).isActive = true

        filter.labels = filters.map { $0.label }
        filter.filterDelegate = self

        card.addSubview(tableView)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: filter.bottomAnchor, constant: 25).isActive = true
        tableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -50).isActive = true
        tableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true

        //tableView.allowsSelection = false
        tableView.rowHeight = 131

        tableView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -5), animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    var workItem: DispatchWorkItem?
    func update() {
        workItem?.cancel()
        let data = libraries
        workItem = Filter.apply(filters: filters, on: data, indices: filter.indexPathsForSelectedItems?.map { $0.row }, completion: {
          filtered in
            self.filteredLibraries = filtered
            self.filteredLibraries.sort(by: self.sortFunc!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    //number of rows to be shown in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLibraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryTableViewCell.kCellIdentifier, for: indexPath) as? LibraryTableViewCell {
            let lib: Library = self.filteredLibraries[indexPath.row]
            cell.nameLabel.text = lib.name
            var distance = Double.nan
            if location != nil {
                distance = lib.getDistanceToUser(userLoc: location!)
            }
            if !distance.isNaN && distance < LibraryViewController.invalidDistance {
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
                guard let imageData = try? Data(contentsOf: lib.imageURL!) else { return }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        //to prevent laggy scrolling
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
}

extension LibraryViewController: FilterViewDelegate {
    
    func filterView(_ filterView: FilterView, didSelect index: Int) {
        update()
    }
    
    func filterView(_ filterView: FilterView, didDeselect index: Int) {
        update()
    }

}
