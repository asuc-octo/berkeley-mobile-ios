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
    
    @IBOutlet var gymName: UILabel!
    @IBOutlet var gymAddress: UIButton!
    
    var gym: Gym?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gymImage.sd_setImage(with: gym?.imageURL!)
        gymInformationTable.delegate = self
        gymInformationTable.dataSource = self
        gymInformationTable.allowsSelection = false
        self.title = gym?.name
        gymName.text = gym?.name
        gymAddress.setTitle(gym?.address, for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gymTime") as! GymTimeCell

            //Determining opening and closing times in PST
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")

            let localOpeningTime = dateFormatter.string(from: (self.gym?.openingTimeToday)!)
            let localClosingTime = dateFormatter.string(from: (self.gym?.closingTimeToday)!)
            
            cell.gymStartEndTime.text = localOpeningTime + " to " + localClosingTime

            var status = "Open"
            if (self.gym?.closingTimeToday!.compare(NSDate() as Date) == .orderedAscending) {
                status = "Closed"
            }
            cell.gymStatus.text = status
            if (status == "Open") {
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
        return 1
    }
    
    @IBAction func openMap(_ sender: Any) {
        
        UIApplication.shared.openURL(NSURL(string: "https://www.google.com/maps/dir/Current+Location/" + String(1.0) + "," + String(1.0))! as URL)
        
    }


}
