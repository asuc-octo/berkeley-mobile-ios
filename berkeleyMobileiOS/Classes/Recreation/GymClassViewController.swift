//
//  GymClassViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymClassViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var gymClassesTableView: UITableView!
    
    let classType = GymClassCategory(name: "AQUA", imageLink: "sdf")

    var gymClasses = [[GymClass]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        gymClassesTableView.dataSource = self
        gymClassesTableView.delegate = self
        
        //Populating the gymClasses array
        for _ in 0...6 {
            gymClasses.append([GymClass]())
        }
        
        //fetch resources for classes
        GymClassDataSource.fetchResources
            {(_ resources: [Resource]?) in
                
                guard let gymClasses = resources as? [GymClass] else
                {
                    print("[ERROR @ RecreationViewController] failed to fetch GymClasses")
                    LoadingScreen.sharedInstance.removeLoadingScreen()
                    return
                }
                
                for gymClass in gymClasses {
                    if (gymClass.class_type == self.classType.name) {
                        
                        let currentCalendar = Calendar.current
                        let currentDate = self.getCurrentDate()
                        let start = currentCalendar.ordinality(of: .day, in: .era, for: currentDate)
                        let end = currentCalendar.ordinality(of: .day, in: .era, for: gymClass.date!)
                        let daysDifference = end! - start!
                        
                        if (daysDifference < 0) {
                            continue
                        }
                        
                        self.gymClasses[daysDifference].append(gymClass)
                    }
                
                }
                
                self.gymClassesTableView.reloadData()
        
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return gymClasses[section].count

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = Bundle.main.loadNibNamed("GymClassTableHeaderView", owner: self, options: nil)?.first as! GymClassTableHeaderView

        let currentDate = getCurrentDate()
        
        let futureDateFormatter = DateFormatter()
        futureDateFormatter.dateStyle = .full
        let futureDate = Date(timeInterval: 24*60*60*(Double(section)), since: currentDate)
        
        //Removing Year from String (last 6 chars)
        var futureDateString = futureDateFormatter.string(from: futureDate)
        let endIndex = futureDateString.index(futureDateString.endIndex, offsetBy: -6)
        futureDateString = futureDateString.substring(to: endIndex)
        headerView.headerDate.text = futureDateString
        
        //Setting up abbreviation for future date
        var futureDateStringArr = futureDateString.components(separatedBy: ",")
        let day = futureDateStringArr[0]
        var abbrev = ""
        let kindex = day.index(day.startIndex, offsetBy: 0)
        let lindex = day.index(day.startIndex, offsetBy: 2)
        if (day[kindex] == "T") || (day[kindex] == "S") {
            abbrev = String(day[Range(kindex ..< lindex)])
        } else {
            abbrev = String(day[kindex])
        }

        headerView.headerAbbreviation.text = abbrev
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (gymClasses[section].count == 0) {
            return 0
        }
        
        return 60
    }
//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gymClass") as! GymClassCell
        
        var gymClass:GymClass?
        
        gymClass = gymClasses[indexPath.section][indexPath.row]
        
        cell.name.text = gymClass!.name
        cell.instructor.text = "Instructor: " + gymClass!.trainer!
        
        //Determining opening and closing times in PST
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        
        let startTime = dateFormatter.string(from: (gymClass!.start_time!))
        let endTime = dateFormatter.string(from: (gymClass!.end_time!))
        
        cell.time.text = startTime + " - " + endTime
        cell.location.text = gymClass!.location!
    
        return cell
    }
    
    func getCurrentDate() -> Date {
        
        let currentDateFormatter = DateFormatter()
        currentDateFormatter.dateStyle = .short
        let currentDateString = currentDateFormatter.string(from: Date())
        
        let PSTFormatter = DateFormatter()
        PSTFormatter.dateFormat = "MM/dd/yy"
        PSTFormatter.timeZone = TimeZone(abbreviation: "PST")
        let exactDate = PSTFormatter.date(from: currentDateString)
        
        return exactDate!
        
    }
    


}
