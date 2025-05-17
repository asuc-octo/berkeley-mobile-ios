//
//  GymsController.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

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
        vc.dropPin(item: vc.filterTableView.filteredData[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath)
        let gym = vc.filterTableView.filteredData[indexPath.row]
        
        cell.contentConfiguration = UIHostingConfiguration {
            HomeSectionListRowView(rowItem: gym)
        }
        return cell
    }
    
}
