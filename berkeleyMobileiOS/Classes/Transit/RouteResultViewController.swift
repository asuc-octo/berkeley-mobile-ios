//
//  RouteResultViewController.swift
//  berkeleyMobileiOS
//
//  Created by Anthony Kim on 3/19/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RouteResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    var routes:[Route]!
    var start:String!
    var end:String!
    var selectedIndexPath = 0
    
    var serverToLocalFormatter = DateFormatter.init()
    var timeFormatter = DateFormatter.init()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTextField.text = start
        endTextField.text = end
        serverToLocalFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        serverToLocalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        serverToLocalFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "h:mm a"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rCell", for: indexPath) as! routeCell
        let route: Route = routes[indexPath.row]
        cell.typeLabel.text = route.busName
        cell.startLabel.text = route.stops[0].name
        

        let currentDate = serverToLocalFormatter.date(from: route.startTime)
        let endDate = serverToLocalFormatter.date(from: route.endTime)
        let timeElapsed = endDate?.timeIntervalSince(currentDate!)
        var minutes = timeElapsed!/60

        cell.timeLabel.text = Int(minutes.rounded()).description + " mins"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        performSegue(withIdentifier: "routeDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! RouteViewController
        let r: Route = self.routes[selectedIndexPath]
        dest.selectedRoute = r
        dest.busType = "Bear Transit"
        dest.name = r.busName
        
        let currentDate = serverToLocalFormatter.date(from: r.startTime)
        let endDate = serverToLocalFormatter.date(from: r.endTime)
        let timeElapsed = endDate?.timeIntervalSince(currentDate!)
        var minutes = timeElapsed!/60
        
        dest.duration = Int(minutes.rounded()).description + " mins"
        dest.time = timeFormatter.string(from: currentDate!)
        
    }
    
    @IBAction func exitAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
}
