//
//  LibraryDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/13/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class LibraryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var libraryImage: UIImageView!
    @IBOutlet var libraryDetailTableView: UITableView!
    var library:Library?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //libraryImage.sd_setImage(with: library?.imageURL!)
        libraryDetailTableView.delegate = self
        libraryDetailTableView.dataSource = self
        self.title = library?.name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "libraryTime") as! LibraryTimeCell
            
            //Converting the date to Pacific time and displaying
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")
            
            let localOpeningTime = dateFormatter.string(from: (self.library?.weeklyOpeningTimes[0])!)
            let localClosingTime = dateFormatter.string(from: (self.library?.weeklyClosingTimes[0])!)
            
            cell.libraryStartEndTime.text = localOpeningTime + " to " + localClosingTime
            
            //Calculating whether the library is open or not
            var status = "OPEN"
            if (self.library?.weeklyClosingTimes[0]?.compare(NSDate() as Date) == .orderedAscending) {
                status = "CLOSED"
            }
            cell.libraryStatus.text = status
            if (status == "OPEN") {
                cell.libraryStatus.textColor = UIColor.green
            } else {
                cell.libraryStatus.textColor = UIColor.red
            }
            
            return cell
        } else if (indexPath.row == 1){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "address") as! AddressCell
            cell.address.text = self.library?.campusLocation
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "libraryPhone") as! LibraryPhoneCell
            cell.phoneNumber.text = self.library?.phoneNumber
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }

}
