//
//  AcademicViewController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/1/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class AcademicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var libButton: UIButton!
    @IBOutlet weak var resourceButton: UIButton!
    
    @IBAction func libModeSelected(_ sender: Any) {
        isLibrary=true
        libButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.alpha = 0.5
        resourceTableView.reloadData()
    }
    
    @IBAction func resourceModeSelected(_ sender: Any) {
        isLibrary = false
        libButton.titleLabel?.textColor = UIColor(hex: "005581")
        libButton.alpha = 0.5
        resourceButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceTableView.reloadData()
    }

    
    @IBOutlet weak var resourceTableView: UITableView!
    var already_loaded = false

    var isLibrary = true
    
    var libraries = [Library]()

    var campusResources = [CampusResource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.alpha = 0.5
        
        Library.dataSource?.fetchResources
            { list in
                
                guard let nonEmptyList = list else
                {
                    // Error
                    return print("no didnt work")
                }
                
                self.libraries = nonEmptyList as! [Library]
                if (self.already_loaded != true) {
                    self.already_loaded = true
                    DispatchQueue.main.async { self.resourceTableView.reloadData() }
                }

        }
        
        CampusResource.dataSource?.fetchResources
            { list in
                
                guard let nonEmptyList = list else
                {
                    // Error
                    return print("no didnt work")
                }
                
                self.campusResources = nonEmptyList as! [CampusResource]
                if (self.already_loaded != true) {
                    self.already_loaded = true
                    DispatchQueue.main.async { self.resourceTableView.reloadData() }
                }
                
        }

        self.resourceTableView.delegate = self
        self.resourceTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        resourceTableView.reloadData()
        
        
    }
    
    //Plots the location of libraries on map view
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = resourceTableView.dequeueReusableCell(withIdentifier: "resource") as! ResourceTableViewCell
        
        if (isLibrary == true) {
            // Populate cells with library information
            let library = libraries[indexPath.row]
            cell.resourceName.text = library.name
            
            if let data = try? Data(contentsOf: library.imageURL!)
            {
                let image: UIImage = UIImage(data: data)!
                cell.resourceImage.image = image
            }
            

            let status = getLibraryStatus(library: library)
            cell.resourceStatus.text = status
            if (status == "Open") {
                cell.resourceStatus.textColor = UIColor.green
            } else {
                cell.resourceStatus.textColor = UIColor.red
            }
            
            let hours = getLibraryHours(library: library)
            cell.resourceHours.text = hours
        } else {
            // Populate cells with campus resource information
            let resource = campusResources[indexPath.row]
            cell.resourceName.text = resource.name
            
            cell.resourceHours.text = resource.hours
        }
    
        return cell
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isLibrary == true) {
            return libraries.count
        } else {
            return campusResources.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isLibrary == true) {
            self.performSegue(withIdentifier: "toLibraryDetail", sender: indexPath.row)
            self.resourceTableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.performSegue(withIdentifier: "toCampusResourceDetail", sender: indexPath.row)
            self.resourceTableView.deselectRow(at: indexPath, animated: true)
        }

    }
    
    
    func getLibraryStatus(library: Library) -> String {
        
        //Determining Status of library
        let todayDate = NSDate()
        
        if (library.weeklyClosingTimes[0] == nil) {
            return "Closed"
        }
        
        var status = "Open"
        if (library.weeklyClosingTimes[0]!.compare(todayDate as Date) == .orderedAscending) {
            status = "Closed"
        }
        
        return status
    }
    
    func getLibraryHours(library: Library) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        var trivialDayStringsORDINAL = ["", "SUN","MON","TUE","WED","THU","FRI","SAT"]
        let dow = Calendar.current.component(.weekday, from: Date())
        let translateddow = (dow - 2 + 7) % 7
        var localOpeningTime = ""
        var localClosingTime = ""
        if let t = (library.weeklyOpeningTimes[translateddow]) {
            localOpeningTime = dateFormatter.string(from:t)
        }
        if let t = (library.weeklyClosingTimes[translateddow]) {
            localClosingTime = dateFormatter.string(from:t)
        }
        
        var timeRange:String = localOpeningTime + " to " + localClosingTime
        var status = "Closed"
        
        if (localOpeningTime == "" && localClosingTime == "") {
            timeRange = "Closed Today"
        } else {
            let openTime = (library.weeklyOpeningTimes[translateddow])!
            let closeTime = (library.weeklyClosingTimes[translateddow])!
            if (openTime < Date() && closeTime > Date()) {
                status = "Open"
            }
        }
        
//        var timeInfo = status + "    " + timeRange
//
//        if (timeRange == "Closed Today") {
//            timeInfo = timeRange
//        }
        return timeRange
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toLibraryDetail") {
            let selectedIndex = sender as! Int
            let selectedLibrary = self.libraries[selectedIndex]

            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem

            let libraryDetailVC = segue.destination as! LibraryDetailViewController

            libraryDetailVC.library = selectedLibrary

        }

    }
}
