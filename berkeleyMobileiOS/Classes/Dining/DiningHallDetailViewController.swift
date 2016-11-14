//
//  DiningHallDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/13/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class DiningHallDetailViewController: UIViewController {
    
    @IBOutlet var diningHallImage: UIImageView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var diningHallName: UILabel!
    @IBOutlet var diningHallAddress: UILabel!
    @IBOutlet var diningHallStatus: UILabel!
    @IBOutlet var diningHallMenuSwitch: UISegmentedControl!
    
    @IBOutlet var diningHallItemsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
