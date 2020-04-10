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
            cell.selectionStyle = .none
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
