//
//  GymsController.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

/**
    Helper to handle Data Source protocols for collections with Gyms.
    Created to split up FitnessViewController.swift, which was bloated.
 */
class GymsController: NSObject {
    
    var vc: FitnessViewController!
}

// MARK: - "Fitness Centers" UITableView

extension GymsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath) as? FilterTableViewCell {
            let gym: Gym = vc.filterTableView.filteredData[indexPath.row]
            cell.nameLabel.text = gym.name
            var distance = Double.nan
            if vc.location != nil {
                distance = gym.getDistanceToUser(userLoc: vc.location!)
            }
            if !distance.isNaN && distance < Gym.invalidDistance {
                cell.timeLabel.text = "\(distance) mi"
            }
            cell.recLabel.text = "Recommended"
            
            if let occ = gym.occupancy, let status = occ.getOccupancyStatus(date: Date()) {
                cell.capBadge.isHidden = false
                switch status {
                case OccupancyStatus.high:
                    cell.capBadge.text = "High"
                    cell.capBadge.backgroundColor = Color.highCapacityTag
                case OccupancyStatus.medium:
                    cell.capBadge.text = "Medium"
                    cell.capBadge.backgroundColor = Color.medCapacityTag
                case OccupancyStatus.low:
                    cell.capBadge.text = "Low"
                    cell.capBadge.backgroundColor = Color.lowCapacityTag
                }
            } else {
                cell.capBadge.isHidden = true
            }
            
            if gym.image == nil {
                cell.cellImage.image = UIImage(named: "DoeGlade")
                DispatchQueue.global().async {
                    if gym.imageURL == nil {
                        return
                    }
                    guard let imageData = try? Data(contentsOf: gym.imageURL!) else { return }
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        gym.image = image
                        if tableView.visibleCells.contains(cell) {
                            cell.cellImage.image = image
                        }
                    }
                }
            } else {
                cell.cellImage.image = gym.image!
            }

            return cell
        }
        return UITableViewCell()
    }
    
}
