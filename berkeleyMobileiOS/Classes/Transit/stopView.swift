//
//  stopView.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 1/18/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class stopView: UIView, UITableViewDelegate, UITableViewDataSource {
    var nearestBusesList: [nearestBus]? = []
    weak var activityIndicatorView: UIActivityIndicatorView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var stopTitle: UILabel!
    @IBOutlet weak var stopTableView: UITableView!
//    init(stopid stopID: String) {
//        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
//        self.stopTitle.text = stopID
//        getBusesFor()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func getBusesFor() {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.stopTableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
        self.activityIndicatorView.startAnimating()
        nearestStopsDataSource.fetchBuses({ (_ buses: [nearestBus]?) in
            if (buses == nil || buses?.count == 0)
            {
                self.stopTitle.text = "No Buses at This Stop"
            }
            self.nearestBusesList = buses
            self.stopTableView.delegate = self
            self.stopTableView.dataSource = self
            self.stopTableView.reloadData()
            self.activityIndicatorView.stopAnimating()
        }, stopCode:self.stopTitle.text!)
        
    }
    
    @IBAction func exitFromView(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.nearestBusesList?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        tableView.register(nearestBusTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "nearestBusTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! nearestBusTableViewCell
        let currentBus: nearestBus = self.nearestBusesList![indexPath.item]
        cell.busTitle.text = currentBus.busName
//        cell.busETA.text = currentBus.timeLeft
        cell.busDirection.text = currentBus.directionTitle
//        cell.detailTextLabel!.text = currentBus.directionTitle
        return cell
    }
    
}
extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
