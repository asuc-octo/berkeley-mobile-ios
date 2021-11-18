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

// MARK: - "Classes" UITableView

extension GymClassesController: UITableViewDataSource {
    
    static let kCellIdentifier = "GymClassTableCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vc.futureClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GymClassesController.kCellIdentifier, for: indexPath)
        if let cell = cell as? EventTableViewCell {
            if let gymClass = vc.futureClasses[safe: indexPath.row] {
                cell.cellConfigure(event: gymClass, type: gymClass.type, color: gymClass.color)
                cell.eventTime.text = gymClass.description(components: [.date, .startTime, .duration, .location])
                
                if let url = gymClass.link, gymClass.location == "Zoom" {
                    let tapGesture = DetailTapGestureRecognizer(target: self, action:
                                                                #selector(GymClassesController.zoomTapped(gesture:)))
                    tapGesture.eventUrl = URL(string: url)
                    
                    cell.cellSetImage(image: UIImage(named: "Zoom Logo")!,
                                      tapGesture: tapGesture)
                }
            }
        }
        return cell
    }
    
    @objc func zoomTapped(gesture: DetailTapGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil, let url = gesture.eventUrl {
            vc.presentAlertLinkUrl(title: Strings.openZoomTitle, message: Strings.Fitness.openGymClassZoomMesssage, website_url: url)
        }
    }
    
}

extension GymClassesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vc.futureClasses[indexPath.row].addToDeviceCalendar(vc: vc)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
