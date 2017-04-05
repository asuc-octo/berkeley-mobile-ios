//
//  RouteViewController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 3/5/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedRoute: Route?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedRoute?.twoTrips)! {
            return 2
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return selectedRoute?.busName
        } else {
            return selectedRoute?.secondBusName
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (selectedRoute?.stops.count)!
        } else {
            return (selectedRoute?.secondRouteStops?.count)!
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        tableView.register(nearestBusTableViewCell.self, forCellReuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailRouteCell", for: indexPath)
        var stopToDisplay: routeStop
        if indexPath.section == 0 {
            stopToDisplay = (selectedRoute?.stops[indexPath.row])!
        } else {
            stopToDisplay = (selectedRoute?.secondRouteStops?[indexPath.row])!
        }
        cell.textLabel?.text = stopToDisplay.name
        return cell
    }
    
    
    @IBAction func exit(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
}
