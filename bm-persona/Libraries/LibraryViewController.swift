//
//  LibraryViewController.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var safeArea: UILayoutGuide!
    let cellSpacingHeight: CGFloat = 14
    var libraries: [Library] = []
    let nearbyButton:ToggleView = {
        let button = ToggleView(origin: .zero, text: "Nearby")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ResourceTableViewCell.self, forCellReuseIdentifier: ResourceTableViewCell.kCellIdentifier)
        self.tableView.dataSource = self
        
        DataManager.shared.fetch(source: LibraryDataSource.self) { libraries in
            self.libraries = libraries as? [Library] ?? []
            self.tableView.reloadData()
        }
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
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        card.addSubview(nearbyButton)
        nearbyButton.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        nearbyButton.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        nearbyButton.addGestureRecognizer(tap)
        
        card.addSubview(tableView)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: nearbyButton.layoutMarginsGuide.topAnchor, constant: 50).isActive = true
        tableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor, constant: -50).isActive = true
        tableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true

        //tableView.allowsSelection = false
        tableView.rowHeight = 131

        //tableView.allowsSelection = false
        tableView.rowHeight = 131
        
        tableView.layer.masksToBounds = false
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        nearbyButton.toggle()
    }
    
    //number of rows to be shown in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ResourceTableViewCell.kCellIdentifier, for: indexPath) as? ResourceTableViewCell {
            let lib: Library = self.libraries[indexPath.row]
            cell.nameLabel.text = lib.name
            let locationManager = CLLocationManager()
            if  let userLoc = locationManager.location,
                let libLat = lib.latitude,
                let libLong = lib.longitude,
                !libLat.isNaN && !libLong.isNaN {
                let libLoc = CLLocation(latitude: libLat, longitude: libLong)
                let distance = round(userLoc.distance(from: libLoc) / 1600.0 * 10) / 10
                cell.timeLabel.text = "\(distance) mi"
            } else {
                cell.timeLabel.text = ""
            }
            cell.recLabel.text = "Recommended"
            cell.selectionStyle = .none
            cell.capBadge.text = "High"
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: lib.imageURL!) else { return }
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.cellImage.image = image
                }
            }
            switch cell.capBadge.text!.lowercased() {
            case "high":
                cell.capBadge.backgroundColor = .red
            case "medium":
                cell.capBadge.backgroundColor = .orange
            case "low":
                cell.capBadge.backgroundColor = .green
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

