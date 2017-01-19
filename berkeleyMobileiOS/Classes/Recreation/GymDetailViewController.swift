//
//  GymDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 1/19/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var gymImage: UIImageView!
    @IBOutlet var gymInformationTable: UITableView!
    var gym: Gym?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gymImage.sd_setImage(with: gym?.imageURL!)
        gymInformationTable.delegate = self
        gymInformationTable.dataSource = self
        self.title = gym?.name

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gymTime") as! GymTimeCell
//            cell.gymStartEndTime.text = self.gym?.openingTimeToday
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")

            let localOpeningTime = dateFormatter.string(from: (self.gym?.openingTimeToday)!)
            let localClosingTime = dateFormatter.string(from: (self.gym?.closingTimeToday)!)
            
            cell.gymStartEndTime.text = localOpeningTime + " to " + localClosingTime

            var status = "OPEN"
            if (self.gym?.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
                status = "CLOSED"
            }
            cell.gymStatus.text = status
            if (status == "OPEN") {
                cell.gymStatus.textColor = UIColor.green
            } else {
                cell.gymStatus.textColor = UIColor.red
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "address") as! AddressCell
            
            cell.address.text = self.gym?.address
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    

}
