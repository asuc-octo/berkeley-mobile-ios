//
//  CampusResourceMapListViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 3/18/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class CampusResourceMapListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var campusResources:[CampusResource]?
    
    
    @IBOutlet var campusResourcesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "campusResource") as! CampusResourceCell
        let campusResource = campusResources?[indexPath.row]
        
        cell.name.text = campusResource?.name
        cell.status.text = campusResource?.hours
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (campusResources?.count)!
    }
    


}
