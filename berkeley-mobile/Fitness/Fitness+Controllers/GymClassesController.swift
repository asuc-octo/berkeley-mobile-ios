//
//  GymClassesController.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

/**
    Helper to handle Data Source protocols for collections with GymClasses.
    Created to split up FitnessViewController.swift, which was bloated.
 */
class GymClassesController: NSObject {
    
    weak var vc: FitnessViewController!
}

// MARK: - "Upcoming" UICollectionView

// Dummy Data
extension GymClassesController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vc.upcomingClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionView.kCellIdentifier, for: indexPath)
        if let card = cell as? CardCollectionViewCell {
            let gymClass = vc.upcomingClasses[indexPath.row]
            card.title.text = gymClass.name
            card.subtitle.text = gymClass.description(components: [.date, .startTime])
            card.badge.text = gymClass.class_type
            card.badge.backgroundColor = gymClass.color
            card.badge.isHidden = gymClass.class_type == nil
        }
        return cell
    }
    
}

// MARK: - "Today" UITableView

extension GymClassesController: UITableViewDataSource {
    
    static let kCellIdentifier = "GymClassTableCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.todayClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GymClassesController.kCellIdentifier, for: indexPath)
        if let cell = cell as? EventTableViewCell {
            let gymClass = vc.todayClasses[indexPath.row]
            cell.eventName.text = gymClass.name
            cell.eventTime.text = gymClass.description(components: [.startTime, .duration, .location])
            cell.eventCategory.text = gymClass.class_type
            cell.eventCategory.backgroundColor = gymClass.color
            cell.eventCategory.isHidden = gymClass.class_type == nil
            cell.eventTaggingColor.backgroundColor = gymClass.color
            
            if let url = gymClass.website_link, gymClass.location == "Zoom" {
                let tapGesture = EventTapGestureRecognizer(target: self, action:
                                                            #selector(GymClassesController.zoomTapped(gesture:)))
                tapGesture.eventUrl = URL(string: url)
                
                cell.cellSetImage(image: UIImage(named: "Zoom Logo")!,
                                  tapGesture: tapGesture)
            }
        }
        return cell
    }
    
    @objc func zoomTapped(gesture: EventTapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            vc.presentAlertLinkUrl(title: "Are you sure you want to open Zoom?", message: "Berkeley Mobile wants to open a online fitness class in Zoom", options: "Cancel", "Yes", website_url: gesture.eventUrl!)
        }
    }
    
}
