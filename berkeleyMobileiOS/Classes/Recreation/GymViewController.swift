//
//  GymViewController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/8/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var gymCollectionView: UICollectionView!
    
    @IBOutlet weak var weekCollectionView: UICollectionView!
    
    @IBOutlet weak var classTypesCollectionView: UICollectionView!
    
    @IBOutlet weak var classTableView: UITableView!
    
    var currentDate = Date()
    
    var gyms = [Gym]()
    
    var gymClasses = [GymClass]() 
    
    var classTypes = ["ALL-AROUND", "CARDIO", "MIND/BODY", "CORE", "DANCE", "STRENGTH", "AQUA"]
    
    var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    var daysOfWeek = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GymClass.dataSource?.fetchResources
            { list in
                //                DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                guard let nonEmptyList = list else
                {
                    // Error
                    return print()
                }
                self.gyms = nonEmptyList as! [Gym]
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
        }
        print(gymClasses.count)
        
        gymCollectionView.delegate = self
        gymCollectionView.dataSource = self
        
        weekCollectionView.delegate = self
        weekCollectionView.dataSource = self
        
        classTypesCollectionView.delegate = self
        classTypesCollectionView.dataSource = self
        
        classTableView.delegate = self
        classTableView.dataSource = self
        
        daysOfWeek = getDaysOfWeek()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.weekCollectionView {
            return 7
        } else if collectionView == self.classTypesCollectionView {
//            return self.gymClasses.count
            return 7 
        } else if collectionView == self.gymCollectionView {
            return self.gyms.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.weekCollectionView {
            let weekCell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekCell", for: indexPath) as! DayCollectionViewCell
            
            weekCell.day.text = dayNames[indexPath.row]
            weekCell.day.textAlignment = .center
            let currDate = daysOfWeek[indexPath.row]
            let calendar = Calendar.current
            let date = calendar.component(.day, from: currDate)
            weekCell.date.text = String(date)
            weekCell.date.textAlignment = .center
            
            if (calendar.component(.day, from: currDate) == calendar.component(.day, from: currentDate)) {
                print("I AM THE SAME")
                weekCell.date.font = UIFont.boldSystemFont(ofSize: 20.0)
                weekCell.day.font = UIFont.boldSystemFont(ofSize: 15.0)
            }
            return weekCell
//        } else if collectionView == self.classTypesCollectionView {
//            let gymCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gymCollectionCell", for: indexPath) as! GymCollectionViewCell
//            let gym = self.gyms[indexPath.row]
//            gymCell.gymName.text = gym.name
//            if (gym.isOpen) {
//                gymCell.gymStatus.text = "OPEN"
//            } else {
//                gymCell.gymStatus.text = "CLOSED"
//            }
//            let gymImage = gym.image
//            gymCell.gymImage.image = gymImage
//
//            return gymCell
//
            
        } else {
            let classTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "classTypeCell", for: indexPath) as! GymClassTypeCollectionViewCell
            let type = classTypes[indexPath.row]
            var color = ""
            switch type {
            case "ALL-AROUND":
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
            classTypeCell.classType.setTitle(type, for: .normal)
            classTypeCell.classType.backgroundColor = UIColor(hex: color)
            classTypeCell.classType.titleLabel?.numberOfLines = 0
//            classTypeCell.classType.width = labelSize(text: type, fontSize: 12, maxWidth: 1000, numberOfLines: 0).width
            classTypeCell.classType.cornerRadius = 15
            return classTypeCell
        }
    }
    

    func labelSize(text: String,fontSize: CGFloat, maxWidth : CGFloat,numberOfLines: Int) -> CGRect{
        
        let font = UIFont.systemFont(ofSize: fontSize)//(name: "HelveticaNeue", size: fontSize)!
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.leastNonzeroMagnitude))
        label.numberOfLines = numberOfLines
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gymClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gymClass", for: indexPath) as! GymClassInfoTableViewCell
        let gymClass = gymClasses[indexPath.row]
        cell.name.text = gymClass.name
        cell.instructor.text = gymClass.trainer
        cell.room.text = gymClass.location
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        
        let startTime = dateFormatter.string(from: (gymClass.start_time!))
        let endTime = dateFormatter.string(from: (gymClass.end_time!))
        
        cell.time.text = startTime + " - " + endTime
        
        return cell
    }
    
    func getDaysOfWeek() -> [Date] {
        var days = [Date]()
        let start = Date().startOfWeek!
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let calendar = Calendar.current
        var currDate = start
        days.append(start)
        for index in 1...6 {
            var nextDate = calendar.date(byAdding: .day, value: 1, to: currDate)
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


