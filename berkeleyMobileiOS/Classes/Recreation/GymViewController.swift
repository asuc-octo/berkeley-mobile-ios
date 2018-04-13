//
//  GymViewController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/8/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
import Firebase
fileprivate let kColorGray = UIColor(white: 189/255.0, alpha: 1)

class GymViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gymCollectionView: UICollectionView!
    
    @IBOutlet weak var weekCollectionView: UICollectionView!
    
    @IBOutlet weak var classTypesCollectionView: UICollectionView!
    
    @IBOutlet weak var classTableView: UITableView!
    
    @IBOutlet weak var noClasses: UILabel!
    var currentDate = Date()
    
    var gyms = [Gym]()
    var selectedGym: Gym!
    
    var gymClasses = [GymClass]()
    var subsetClasses = [GymClass]()
    
    
    var selectedClassTypes: [String] = []
    var classBool = [true, true, true, true, true, true, true]
    var selectedDays: Date! = Date()
    var classTypes: [String] = []
//    var classTypes = ["ALL-AROUND", "CARDIO", "MIND/BODY", "CORE", "DANCE", "STRENGTH", "AQUA"]
    
    var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    var daysOfWeek = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noClasses.isHidden = true
        Gym.dataSource?.fetchResources
            { list in
                //                DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                guard let nonEmptyList = list else
                {
                    // Error
                    return print("Failed to load gyms in GymViewController")
                }
                self.gyms = nonEmptyList as! [Gym]
                if let t = self.gymCollectionView {
                    t.reloadData()
                }
        }
        // Set up gym classes
        GymClass.dataSource?.fetchResources
            { list in
//                DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                guard let nonEmptyList = list else
                {
                    // Error
                    return print()
                }
                self.gymClasses = nonEmptyList as! [GymClass]
            
                let calendar = Calendar.current
                var tempClasses = [GymClass]()
                var found_types: Set<String> = Set()
                for gymClass in self.gymClasses {
                    if let gymDate = gymClass.date {
                        if let gc = gymClass.class_type {
                            found_types.insert(gc)
                            if (calendar.component(.day, from: gymDate) == calendar.component(.day, from: self.selectedDays)) {
                                tempClasses.append(gymClass)
                            }
                        }
                    }
 
                }
                
                self.subsetClasses = tempClasses
                var ref: [String] = ["ALL-AROUND WORKOUT", "CARDIO", "MIND/BODY", "CORE", "DANCE", "STRENGTH", "AQUA"]
                self.classTypes = []
                for s in ref {
                    if found_types.contains(s) {
                        self.classTypes.append(s)
                    }
                }
                self.selectedClassTypes = self.classTypes
                
                if let t = self.classTableView {
                    t.reloadData()
                    self.noClasses.isHidden = false
                    self.noClasses.text = "No Classes for Selected Options"
                }
//                self.tableViewHeight.constant = self.height_from_count(self.subsetClasses.count)
                self.tableViewHeight.constant = self.height_from_count()
                self.classTypesCollectionView.reloadData()
        }
        
        gymCollectionView.delegate = self
        gymCollectionView.dataSource = self
        
        weekCollectionView.delegate = self
        weekCollectionView.dataSource = self
        
        classTypesCollectionView.delegate = self
        classTypesCollectionView.dataSource = self
        
        classTableView.delegate = self
        classTableView.dataSource = self
        
        daysOfWeek = getDaysOfWeek()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func height_from_count() -> CGFloat {
        return CGFloat((self.subsetClasses.count) * Int(55))
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.weekCollectionView {
            return 7
        } else if collectionView == self.classTypesCollectionView {
            return self.classTypes.count
        } else if collectionView == self.gymCollectionView {
            return self.gyms.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.weekCollectionView {
            let weekCell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekCell", for: indexPath) as! DayCollectionViewCell
            let dow = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
            weekCell.day.text = dayNames[(indexPath.row + dow - 1) % dayNames.count]
            weekCell.day.textAlignment = .center
            let currDate = daysOfWeek[indexPath.row]
            let calendar = Calendar.current
            let date = calendar.component(.day, from: currDate)
            weekCell.date.text = String(date)
            weekCell.date.textAlignment = .center
            weekCell.date.font = UIFont.init(name: "Roboto", size: 16)
            weekCell.day.font = UIFont.init(name: "Roboto", size: 11)
            weekCell.date.textColor = UIColor(hex: "5B5B5B")
            weekCell.day.textColor = UIColor(hex: "5B5B5B")
            if (calendar.component(.day, from: currDate) == calendar.component(.day, from: selectedDays)) {
                weekCell.date.font = UIFont.init(name: "Roboto-Bold", size: 20)
                weekCell.day.font = UIFont.init(name: "Roboto-Bold", size: 13)
                weekCell.date.textColor = UIColor(hex: "2A2A2A")
                weekCell.day.textColor = UIColor(hex: "2A2A2A")
            }
            return weekCell
        } else if collectionView == self.gymCollectionView {
            let gymCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gymCollectionCell", for: indexPath) as! GymCollectionViewCell
            let gym = self.gyms[indexPath.row]
            gymCell.gymName.text = gym.name
            let layer = gymCell.layer
            layer.borderWidth = 1
            layer.borderColor = kColorGray.cgColor
            layer.masksToBounds = false
            layer.shadowRadius = 2.0
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 1.0, height: 1.0)

            if (gym.isOpen) {
                gymCell.gymStatus.text = "OPEN"
                gymCell.gymStatus.textColor = UIColor(hex: "18A408")
            } else {
                gymCell.gymStatus.text = "CLOSED"
                gymCell.gymStatus.textColor = UIColor(hex: "FF2828")
            }
            if gym.name == "Recreational Sports Facility (RSF)" {
                gymCell.gymImage.image = #imageLiteral(resourceName: "rsf")
            } else {
                gymCell.gymImage.load(resource: gym)
            }
            return gymCell
        } else {
            let classTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "classTypeCell", for: indexPath) as! GymClassTypeCollectionViewCell
            let type = classTypes[indexPath.row]
            var color = ""
            switch type {
            case "ALL-AROUND WORKOUT":
                color = "10CEB4"
            case "CARDIO":
                color = "FD2BA8"
            case "MIND/BODY":
                color = "FFB109"
            case "CORE":
                color = "3B90F7"
            case "DANCE":
                color = "8E31FF"
            case "STRENGTH":
                color = "FF720A"
            case "AQUA":
                color = "3EB7D2"
            default:
                color = ""
            }
  
            
            classTypeCell.selectedBool = self.classBool[indexPath.row]
            classTypeCell.classType.text = type.split(separator: " ").first?.uppercased()
            classTypeCell.classType.layer.cornerRadius = 10
            classTypeCell.classType.layer.masksToBounds = true
            print(self.classBool)
            if ( classTypeCell.selectedBool) {
                classTypeCell.classType.backgroundColor = UIColor(hex: color)
                classTypeCell.classType.textColor = UIColor.white
                classTypeCell.classType.borderColor = UIColor(hex: color)

            } else {
                classTypeCell.classType.backgroundColor = UIColor.white
                classTypeCell.classType.textColor = UIColor(hex: color)
                classTypeCell.classType.borderColor = UIColor(hex: color)
                classTypeCell.classType.borderWidth = 1.0
                
            }
            return classTypeCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.gymCollectionView {
            selectedGym = self.gyms[indexPath.row]
            performSegue(withIdentifier: "toGym", sender: self)
        } else if collectionView == self.weekCollectionView {
            Analytics.logEvent("gym_date_clicked", parameters: nil)

            //  Reload table to only show stuff for that day
            var clickedDay = self.daysOfWeek[indexPath.row]
            if (selectedDays != clickedDay) {
                // Here we want to swap which one is bolded
                selectedDays = clickedDay
                let calendar = Calendar.current
                var tempClasses = [GymClass]()
                for gymClass in self.gymClasses {
                    let gymDate = gymClass.date
                    if (gymDate != nil && calendar.component(.day, from: gymDate!) == calendar.component(.day, from: selectedDays)) {
                        if (self.selectedClassTypes.contains(gymClass.class_type!)) {
                        tempClasses.append(gymClass)
                        }
                    }
                }
                subsetClasses = tempClasses
            }
            
            self.classTableView.reloadData()
            self.weekCollectionView.reloadData()
        } else if collectionView == self.classTypesCollectionView {
            Analytics.logEvent("clicked_exercise_filter", parameters: nil)
            // Reload table to only show stuff for selected class types
            var selectedType = self.classTypes[indexPath.row]
            if (!self.selectedClassTypes.contains(selectedType)) {
                self.selectedClassTypes.append(selectedType)
                self.classBool[indexPath.row] = true
         
                var tempClasses = [GymClass]()
                
                for gymClass in self.gymClasses {
                    let classType = gymClass.class_type
                    if (classType == selectedType) {
                        let calendar = Calendar.current
                        if let gymDate = gymClass.date {
                            let cd = calendar.component(.day, from: gymDate)
                            let dd = calendar.component(.day, from: selectedDays)
                            if (cd == dd) {
                                tempClasses.append(gymClass)
                            }
                        }

                    }
                }
                subsetClasses.append(contentsOf: tempClasses)
                self.tableViewHeight.constant = height_from_count()

            } else {
                self.selectedClassTypes.remove(at: self.selectedClassTypes.index(of: selectedType)!)
                
                self.classBool[indexPath.row] = false
                var tempClasses = [GymClass]()

                for gymClass in subsetClasses {
                    let classType = gymClass.class_type
                    if (self.selectedClassTypes.contains(classType!)) {
                        tempClasses.append(gymClass)
                    }
                }
                subsetClasses = tempClasses
                self.tableViewHeight.constant = height_from_count()

            }
            self.classTypesCollectionView.reloadData()
            self.classTableView.reloadData()
        }
 
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toGym" {
                if let dest = segue.destination as? SpecificGymViewController {
                    dest.gym = selectedGym
                }
            }
        }
    }
    
    // SHIT (i.e. tableview) FOR GYM CLASSES BYOOTCH
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if subsetClasses.count == 0 {
            self.classTableView.isHidden = true
        } else {
            self.classTableView.isHidden = false
        }
        return subsetClasses.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gymClass", for: indexPath) as! GymClassInfoTableViewCell
        let gymClass = subsetClasses[indexPath.row]
        let classType = gymClass.class_type
        
        cell.name.text = gymClass.name
        cell.instructor.text = gymClass.trainer
        
        let loc = gymClass.location
        if (loc?.characters.contains(","))! {
            cell.room.text = loc?.components(separatedBy:", ")[0]
            cell.gym.text = loc?.components(separatedBy:", ")[1]
        } else {
            cell.room.text = loc
            cell.gym.text = ""
        }

        let type = gymClass.class_type
        var color = ""
        switch type {
        case "ALL-AROUND WORKOUT"?:
            color = "10CEB4"
        case "CARDIO"?:
            color = "FD2BA8"
        case "MIND/BODY"?:
            color = "FFB109"
        case "CORE"?:
            color = "3B90F7"
        case "DANCE"?:
            color = "8E31FF"
        case "STRENGTH"?:
            color = "FF720A"
        case "AQUA"?:
            color = "3EB7D2"
        default:
            color = ""
        }
        
        cell.sidebarColor.backgroundColor = UIColor(hex: color)
    
        
        let startTime = gymClass.start_time
        let endTime = gymClass.end_time

        let calendar = Calendar.current
        
        var startHr = calendar.component(.hour, from: startTime!) % 12
        if (startHr == 0) {
            startHr = 12
        }
        var startMin = calendar.component(.minute, from: startTime!)
        var endHr = calendar.component(.hour, from: endTime!) % 12
        if(endHr == 0) {
            endHr == 12
        }
        var endMin = calendar.component(.minute, from: endTime!)
        var ampm = calendar.component(.era, from: endTime!)
        var startStr = ""
        var endStr = ""
        if (startMin == 0) {
            startStr = String(startHr) + ":00"
        } else {
            startStr = String(startHr) + ":" + String(startMin)
        }
        if (endMin == 0) {
            endStr = String(endHr) + ":00"
        } else {
            endStr = String(endHr) + ":" + String(endMin)
        }
        let formatter = DateFormatter()
//        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
//        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "a"
//        formatter.AMSymbol = "AM"
//        formatter.PMSymbol = "PM"
        let dateString = formatter.string(from: endTime!)
        let time = startStr + " - " + endStr + " " + dateString
        
        cell.time.text = time
        
        return cell
    }
    
    func getDaysOfWeek() -> [Date] {
        var days = [Date]()
        let start = Date()
        let calendar = Calendar.current
        var currDate = start
        days.append(start)
        for _ in 1...6 {
            let nextDate = calendar.date(byAdding: .day, value: 1, to: currDate)
            days.append(nextDate!)
            currDate = nextDate!
        }
        return days
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToGym(segue: UIStoryboardSegue) {
    }
    
    
    
}
extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        
        return gregorian.date(byAdding: .day, value: 0, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    
}




