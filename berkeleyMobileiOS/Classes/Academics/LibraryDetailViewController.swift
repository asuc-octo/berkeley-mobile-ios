//
//  LibraryDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/13/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import RealmSwift

class LibraryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var libraryImage: UIImageView!
    @IBOutlet var libraryDetailTableView: UITableView!
    
    @IBOutlet var libraryName: UILabel!
    @IBOutlet var libraryAddress: UIButton!
    
    var library:Library?
    var realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //libraryImage.sd_setImage(with: library?.imageURL!)
        libraryDetailTableView.delegate = self
        libraryDetailTableView.dataSource = self
        self.title = library?.name
        libraryName.text = library?.name
        libraryAddress.setTitle(library?.campusLocation, for: .normal)
        
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
            var status = "Open"
            if (self.library?.weeklyClosingTimes[0]?.compare(NSDate() as Date) == .orderedAscending) {
                status = "Closed"
            }
            cell.libraryStatus.text = status
            if (status == "Open") {
                cell.libraryStatus.textColor = UIColor.green
            } else {
                cell.libraryStatus.textColor = UIColor.red
            }
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "libraryOption") as! LibraryOptionsCell
            // For favoriting
            if (library?.favorited == true) {
                cell.libraryFavoriteButton.setImage(UIImage(named:"heart-large-filled"), for: .normal)
            } else {
                cell.libraryFavoriteButton.setImage(UIImage(named:"heart-large"), for: .normal)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    @IBAction func callLibrary(_ sender: Any) {
        let numberArray = self.library?.phoneNumber?.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        var number = ""
        for n in numberArray! {
            number += n
        }
        
        if let url = URL(string: "telprompt://\(number)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func favoriteLibrary(_ sender: Any) {
        
        library?.favorited = !(library?.favorited!)!
        
        //Realm adding and deleting favorite libraries
        let favLibrary = FavoriteLibrary()
        favLibrary.name = (library?.name)!
        
        if (library?.favorited == true) {
            (sender as! UIButton).setImage(UIImage(named:"heart-large-filled"), for: .normal)
        } else {
            (sender as! UIButton).setImage(UIImage(named:"heart-large"), for: .normal)
        }
        
        if (library?.favorited)! {
            try! realm.write {
                realm.add(favLibrary)
            }
        } else {
            let libraries = realm.objects(FavoriteLibrary.self)
            for lib in libraries {
                if lib.name == library?.name {
                    try! realm.write {
                        realm.delete(lib)
                    }
                }
            }
        }
    }

    @IBAction func viewLibraryMap(_ sender: Any) {
        
        let lat = library?.latitude!
        let lon = library?.longitude!
        
        UIApplication.shared.open(NSURL(string: "https://www.google.com/maps/dir/Current+Location/" + String(describing: lat!) + "," + String(describing: lon!))! as URL,  options: [:], completionHandler: nil)

    }
}
