//
//  AcademicViewController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/1/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kColorRed = UIColor.red
fileprivate let kColorGray = UIColor(white: 189/255.0, alpha: 1)
fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)

class AcademicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ResourceCellDelegate {

    @IBOutlet weak var banner: UIImageView!

    @IBOutlet weak var libButton: UIButton!
    @IBOutlet weak var resourceButton: UIButton!
    
    @IBAction func libModeSelected(_ sender: Any) {
        isLibrary=true
        libButton.titleLabel?.textColor = UIColor(hex: "005581")
        libButton.alpha = 1.0
        resourceButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.alpha = 0.5
        self.sortBy = .favorites
    }
    
    @IBAction func resourceModeSelected(_ sender: Any) {
        isLibrary = false
        libButton.titleLabel?.textColor = UIColor(hex: "005581")
        libButton.alpha = 0.5
        resourceButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.alpha = 1.0
        resourceTableView.reloadData()
        Analytics.logEvent("opened_resource_screen", parameters: nil)
    }

    @IBAction func unwindToAcademic(segue: UIStoryboardSegue) {
    }
    
    @IBAction func libraryUnwind(segue: UIStoryboardSegue) {
    }
    
    
    @IBOutlet weak var resourceTableView: UITableView!
    var already_loaded = false

    var isLibrary = true
    
    var libraries = [Library]()

    var campusResources = [CampusResource]()
    var favLib = [Library]()
    var nonFavLib = [Library]()
    
    public var sortBy: FavorableSortBy = .favorites
    {
        didSet
        {
            if isLibrary {
                libraries.sort(by: sortBy.comparator)
            }
            resourceTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Library.dataSource?.fetchResources
            { list in
                
                guard let nonEmptyList = list else
                {
                    // Error
                    return print("no didnt work")
                }
                
                self.libraries = nonEmptyList as! [Library]
                if self.resourceTableView != nil {
                    self.sortBy = .favorites
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
                if let t = self.resourceTableView {
                    t.reloadData()
                }
        }
        
        // Check to see if user setting for favoriting exists
        let defaults = UserDefaults.standard
        if (UserDefaults.standard.object(forKey: "favoritedLibraries") == nil) {
            // No favoriting enabled (first time opening libraries) - no favorites
            defaults.set(favLib, forKey:"favoritedLibraries")
        } else {
            favLib = defaults.object(forKey: "favoritedLibraries") as! [Library]
            for lib in self.libraries {
                for favL in favLib {
                    if (lib.name != favL.name) {
                        nonFavLib.append(lib)
                    }
                }
            }
        }
        
        self.libraries = favLib + nonFavLib


    }

    override func viewWillAppear(_ animated: Bool) {
        libButton.titleLabel?.textColor = UIColor(hex: "005581")
        resourceButton.titleLabel?.textColor = UIColor(hex: "005581")
        if isLibrary {
            resourceButton.alpha = 0.5
        } else {
            libButton.alpha = 0.5
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.resourceTableView.delegate = self
        self.resourceTableView.dataSource = self
        resourceTableView.reloadData()
        //banner.backgroundColor = UIColor(hex: "1A5679")
        banner.backgroundColor = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
        Analytics.logEvent("opened_library_screen", parameters: nil)
    }
    
    //Plots the location of libraries on map view
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ResourceCellDelegate
    
    func didFavoriteItem() {
        self.sortBy = .favorites
    }
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (isLibrary == true) {
            let cell = resourceTableView.dequeueReusableCell(withIdentifier: "resource") as! ResourceTableViewCell
            // Populate cells with library information
            let library = libraries[indexPath.row]
            cell.delegate = self
            cell.library = library
            cell.resourceName.text = library.name
            cell.resourceImage.load(resource: library)
            cell.favoriteButton.isSelected = library.isFavorited
            
            var status = "OPEN"
            if library.isOpen == false {
                status = "CLOSED"
            }
            cell.resourceStatus.text = status

            if (status == "OPEN") {
                cell.resourceStatus.textColor = UIColor(hex: "18A408")
            } else {
                cell.resourceStatus.textColor = UIColor(hex: "FF2828")
            }
            
            let hours = getLibraryHours(library: library)
            cell.resourceHours.text = hours
            cell.resourceHours.textColor = UIColor(hex: "585858")
            
            var splitStr = hours.components(separatedBy: " to ")
            if (splitStr.count == 2) {
                if (splitStr[0] == splitStr[1]) {
                    cell.resourceStatus.textColor = UIColor(hex: "18A408")
                    cell.resourceStatus.text = "OPEN"
                    cell.resourceStatus.textColor = UIColor(hex:"18A408")
                }
            }
            
            return cell
        } else {
            let cell = resourceTableView.dequeueReusableCell(withIdentifier: "campus_resource") as! CampusResourceTableViewCell

            // Populate cells with campus resource information
            let resource = campusResources[indexPath.row]
            cell.main_image.load(resource: resource)
            cell.resource_name.text = resource.name
            cell.category_name.text = resource.category
            
//            cell.resourceHours.text = resource.hours
            return cell
        }
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isLibrary == true) {
            return 80
        } else {
            return UITableViewAutomaticDimension
        }
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
        let dow = Calendar.current.component(.weekday, from: Date())
        let translateddow = 0
        var localOpeningTime = ""
        var localClosingTime = ""
        if let t = (library.weeklyOpeningTimes[translateddow]) {
            localOpeningTime = dateFormatter.string(from:t)
        }
        if let t = (library.weeklyClosingTimes[translateddow]) {
            localClosingTime = dateFormatter.string(from:t)
        }
        
        var timeRange:String = localOpeningTime + " to " + localClosingTime
        
        
        if (localOpeningTime == "" && localClosingTime == "") {
            timeRange = "Closed Today"
        }
        return timeRange
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toLibraryDetail") {
            let selectedIndex = sender as! Int
            let selectedLibrary = self.libraries[selectedIndex]

            let libraryDetailVC = segue.destination as! LibraryViewController

            libraryDetailVC.library = selectedLibrary

        }
        if (segue.identifier == "toCampusResourceDetail") {
            let selectedIndex = sender as! Int
            let selectedCampRes = self.campusResources[selectedIndex]

            let campusResourceDetailVC = segue.destination as! CampusResourceViewController
            
            campusResourceDetailVC.campusResource = selectedCampRes
        }

    }
}
