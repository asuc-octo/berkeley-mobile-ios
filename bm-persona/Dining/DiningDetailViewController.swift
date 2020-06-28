//
//  DiningDetailViewController.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class DiningDetailViewController: SearchDrawerViewController {
    
    var diningHall: DiningLocation!
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var overviewCard: OverviewCardView!
    var control: TabBarControl!
    var meals: MealMap!
    var mealNames: [MealType]!
    var menuView: FilterTableView = FilterTableView<DiningItem>(frame: .zero, filters: [])
    static let cellHeight: CGFloat = 45
    static let cellSpacingHeight: CGFloat = 5
    static let mealTimesChronological = ["breakfast": 0, "brunch": 1, "lunch": 2, "dinner": 3, "late night": 4, "other": 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        setUpOverviewCard()
        setUpMenuControl()
        setUpMenu()
        view.layoutSubviews()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        // set the bottom cutoff point for when drawer appears
        // the "middle" position for the view will show everything in the overview card
        middleCutoffPosition = overviewCard.frame.maxY + 8
    }
}

extension DiningDetailViewController {
    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: diningHall, excludedElements: [.address, .distance, .openTimes, .phone], userLocation: location)
        view.addSubview(overviewCard)
        overviewCard.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        overviewCard.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.layoutSubviews()
    }
    
    func setUpMenuControl() {
        meals = diningHall.meals
        if meals.count == 0 {
            return
        }
        let size = CGSize(width: view.frame.width - view.layoutMargins.left - view.layoutMargins.right, height: 35)
        control = TabBarControl(frame: CGRect(origin: .zero, size: size),
                                barHeight: CGFloat(13),
                                barColor: UIColor(displayP3Red: 250/255.0, green: 212/255.0, blue: 126/255.0, alpha: 1.0))
        control.delegate = self
        view.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        control.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        /*Sort meal times chronologically using the mealTimesChronological dictionary
         Currently supports Breakfast, Brunch, Lunch, Dinner, Late Night*/
        mealNames = Array(meals.keys).sorted(by: { (meal1, meal2) -> Bool in
            let m1Priority = DiningDetailViewController.mealTimesChronological[meal1.lowercased()] ??
                DiningDetailViewController.mealTimesChronological["other"]!
            let m2Priority = DiningDetailViewController.mealTimesChronological[meal2.lowercased()] ??
                DiningDetailViewController.mealTimesChronological["other"]!
            return m1Priority < m2Priority
        })
        control.setItems(mealNames)
        control.index = 0
    }
    
    func setUpMenu() {
        var filters: [Filter<DiningItem>] = [Filter<DiningItem>]()
        //Add filters for some common restrictions
        filters.append(filterForRestriction(name: "Vegetarian", restriction: KnownRestriction.vegetarian, matches: true))
        filters.append(filterForRestriction(name: "Vegan", restriction: KnownRestriction.vegan, matches: true))
        filters.append(filterForRestriction(name: "Gluten-Free", restriction: KnownRestriction.gluten, matches: false))
        filters.append(filterForRestriction(name: "Kosher", restriction: KnownRestriction.kosher, matches: true))
        filters.append(filterForRestriction(name: "Halal", restriction: KnownRestriction.halal, matches: true))
        filters.append(filterForRestriction(name: "No Tree Nuts", restriction: KnownRestriction.treenut, matches: false))
        filters.append(filterForRestriction(name: "No Peanuts", restriction: KnownRestriction.peanut, matches: false))
        filters.append(filterForRestriction(name: "No Pork", restriction: KnownRestriction.pork, matches: false))
        //        filters.append(filterForRestriction(name: "No Milk", restriction: KnownRestriction.milk, matches: false))
        //        filters.append(filterForRestriction(name: "Fish", restriction: KnownRestriction.fish, matches: true))
        //        filters.append(filterForRestriction(name: "No Shellfish", restriction: KnownRestriction.shellfish, matches: false))
        //        filters.append(filterForRestriction(name: "No Egg", restriction: KnownRestriction.egg, matches: false))
        //        filters.append(filterForRestriction(name: "No Alcohol", restriction: KnownRestriction.alcohol, matches: false))
        //        filters.append(filterForRestriction(name: "Soybeans", restriction: KnownRestriction.soybean, matches: true))
        //        filters.append(filterForRestriction(name: "Wheat", restriction: KnownRestriction.wheat, matches: true))
        //        filters.append(filterForRestriction(name: "No Sesame", restriction: KnownRestriction.sesame, matches: false))
        menuView = FilterTableView(frame: .zero, filters: filters)
        self.menuView.tableView.register(DiningMenuCell.self, forCellReuseIdentifier: DiningMenuCell.kCellIdentifier)
        self.menuView.tableView.dataSource = self
        self.menuView.tableView.delegate = self
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuView)
        self.menuView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        self.menuView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        self.menuView.topAnchor.constraint(equalTo: control.bottomAnchor, constant: kViewMargin).isActive = true
        self.menuView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        //TODO: sort func? currently same order as read in
        self.menuView.setData(data: meals[mealNames[control.index]]!)
        self.menuView.tableView.reloadData()
    }
    
    /*Create a filter named NAME which filters based on RESTRICTION.
     If MATCHES is true: includes items with RESTRICTION.
     If MATCHES is false: excludes items with RESTRICTION.*/
    func filterForRestriction(name: String, restriction: KnownRestriction, matches: Bool) -> Filter<DiningItem> {
        if matches {
            return Filter<DiningItem>(label: name, filter: {item in
                item.restrictions.contains(where: { (restr) -> Bool in
                    return restr.known != nil && restr.known == restriction
                })})
        } else {
            return Filter<DiningItem>(label: name, filter: {item in
                !item.restrictions.contains(where: { (restr) -> Bool in
                    return restr.known != nil && restr.known == restriction
                })})
        }
    }
}

extension DiningDetailViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation
        DispatchQueue.main.async {
            self.overviewCard.updateLocation(userLocation: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension DiningDetailViewController: TabBarControlDelegate {
    func tabBarControl(_ tabBarControl: TabBarControl, didChangeValue value: Int) {
        control.index = value
        self.menuView.setData(data: meals[mealNames[control.index]]!)
        self.menuView.tableView.reloadData()
    }
}

extension DiningDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: DiningMenuCell.kCellIdentifier, for: indexPath) as? DiningMenuCell {
            let item: DiningItem = self.menuView.filteredData[indexPath.row]
            cell.nameLabel.text = item.name
            cell.item = item
            cell.setRestrictionIcons()
            cell.updateFaveButton()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DiningDetailViewController.cellHeight + DiningDetailViewController.cellSpacingHeight
    }
}
