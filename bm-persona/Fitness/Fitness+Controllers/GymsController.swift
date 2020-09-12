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
    
    weak var vc: FitnessViewController!
}

// MARK: - "Fitness Centers" UITableView

extension GymsController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vc.presentDetail(type: Gym.self, item: vc.filterTableView.filteredData[indexPath.row], containingVC: vc.mainContainer!, position: .full)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath) as? FilterTableViewCell {
            let gym: Gym = vc.filterTableView.filteredData[indexPath.row]
            cell.updateContents(item: gym, imageUpdate: {
                DispatchQueue.global().async {
                    guard let imageURL = gym.imageURL, let imageData = try? Data(contentsOf: imageURL) else { return }
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        gym.image = image
                        if tableView.visibleCells.contains(cell) {
                            cell.cellImage.image = image
                        }
                    }
                }
            })
            return cell
        }
        return UITableViewCell()
    }
    
}
