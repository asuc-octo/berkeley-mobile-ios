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
    
//    var gymClasses = [GymClass]()
    
    var gymClasses = [[GymClass]]()
    
//    var todayClasses = [GymClass](), oneDayAheadClasses = [GymClass](), twoDaysAheadClasses = [GymClass](),
//        threeDaysAheadClasses = [GymClass](), fourDaysAheadClasses = [GymClass](), fiveDaysAheadClasses = [GymClass](),
//        sixDaysAheadClasses = [GymClass]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gymClassesTableView.dataSource = self
        gymClassesTableView.delegate = self
        
        for _ in 0...6 {
            gymClasses.append([GymClass]())
        }
        
        //fetch resources for class too
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
                    

                        let myFormatter = DateFormatter()
                        myFormatter.dateStyle = .short
//                        myFormatter.timeStyle = .short
                        
                        let s = myFormatter.string(from: Date())
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yy"
                        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
                        let currentDate = dateFormatter.date(from: s)
                        
//                        print(currentDate)
                        
                        let start = currentCalendar.ordinality(of: .day, in: .era, for: currentDate!)
                        let end = currentCalendar.ordinality(of: .day, in: .era, for: gymClass.date!)
                        let daysDifference = end! - start!
                        
                        if (daysDifference < 0) {
                            continue
                        }
                        
                        self.gymClasses[daysDifference].append(gymClass)
                        
//                        if (daysDifference == 0) {
//                            self.todayClasses.append(gymClass)
//                        } else if (daysDifference == 1) {
//                            self.oneDayAheadClasses.append(gymClass)
//                        } else if (daysDifference == 2) {
//                            self.twoDaysAheadClasses.append(gymClass)
//                        } else if (daysDifference == 3) {
//                            self.threeDaysAheadClasses.append(gymClass)
//                        } else if (daysDifference == 4) {
//                            self.fourDaysAheadClasses.append(gymClass)
//                        } else if (daysDifference == 5) {
//                            self.fiveDaysAheadClasses.append(gymClass)
//                        } else if (daysDifference == 6) {
//                            self.sixDaysAheadClasses.append(gymClass)
//                        }
                        
                    }
                        
                        //Calculate difference in days
//                        
//                        self.gymClasses.append(gymClass)
                
                }
                
                self.gymClassesTableView.reloadData()
        
        }
        
        

        // Do any additional setup after loading the view.
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
        
//        if (section == 0) {
//            return todayClasses.count
//        } else if (section == 1) {
//            return oneDayAheadClasses.count
//        } else if (section == 2) {
//            return twoDaysAheadClasses.count
//        } else if (section == 3) {
//            return threeDaysAheadClasses.count
//        } else if (section == 4) {
//            return fourDaysAheadClasses.count
//        } else if (section == 5) {
//            return fiveDaysAheadClasses.count
//        } else {
//            return sixDaysAheadClasses.count
//        }

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
//        gymClasses[section]
        
        let myFormatter = DateFormatter()
        myFormatter.dateStyle = .short
        let s = myFormatter.string(from: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        let currentDate = dateFormatter.date(from: s)

        
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .full
        let exactDate = Date(timeInterval: 24*60*60*(Double(section)), since: currentDate!)
        
        let r = formatter2.string(from: exactDate)

        return r
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gymClass") as! GymClassCell
        
        var gymClass:GymClass?
        
        gymClass = gymClasses[indexPath.section][indexPath.row]
        
//        if (indexPath.section == 0) {
//            gymClass = todayClasses[indexPath.row]
//        } else if (indexPath.section == 1) {
//            gymClass = oneDayAheadClasses[indexPath.row]
//        } else if (indexPath.section == 2) {
//            gymClass = twoDaysAheadClasses[indexPath.row]
//        } else if (indexPath.section == 3) {
//           gymClass = threeDaysAheadClasses[indexPath.row]
//        } else if (indexPath.section == 4) {
//           gymClass = fourDaysAheadClasses[indexPath.row]
//        } else if (indexPath.section == 5) {
//            gymClass = fiveDaysAheadClasses[indexPath.row]
//        } else {
//            gymClass = sixDaysAheadClasses[indexPath.row]
//        }
//    
        
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


}
