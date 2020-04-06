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

class DiningDetailViewController: UIViewController {
    
    var diningHall: DiningHall!
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var control: TabBarControl!
    var meals: MealMap!
    var mealNames: [MealType]!
    var menuView: FilterTableView = FilterTableView<DiningItem>(frame: .zero, filters: [])
    static let cellHeight: CGFloat = 45
    static let cellSpacingHeight: CGFloat = 5
    static let mealTimesChronological = ["breakfast": 0, "brunch": 1, "lunch": 2, "dinner": 3, "late night": 4, "other": 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        locationManager.delegate = self
        setUpOverviewCard()
        setupMenuControl()
        setupMenu()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(24)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 2
        return label
    }()
    
    let card: CardView = {
        let card = CardView()
        card.isUserInteractionEnabled = true
        card.layoutMargins = kCardPadding
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    let diningImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let addressIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Placemark")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    let clockIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Clock")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let openTimeLabel: UILabel = {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    let openTag: TagView = {
        let tag = TagView(origin: .zero, text: "", color: .clear)
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
    
    let chairImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Chair")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let capBadge:TagView = {
        let cap = TagView(origin: .zero, text: "", color: .clear)
        cap.translatesAutoresizingMaskIntoConstraints = false
        return cap
    }()
    
    let faveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(toggleFave(sender:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let phoneIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Phone")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let phoneLabel: UILabel =  {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
    
    let distIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Walk")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let distLabel: UILabel =  {
        let label = UILabel()
        label.font = Font.light(12)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()
}

extension DiningDetailViewController {
    
    func setUpOverviewCard() {
        view.layoutMargins = UIEdgeInsets(top: kViewMargin, left: kViewMargin, bottom: kViewMargin, right: kViewMargin)
        
        view.addSubview(card)
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.layoutSubviews()
        
        card.addSubview(clockIcon)
        card.addSubview(openTimeLabel)
        card.addSubview(openTag)
        card.addSubview(chairImage)
        card.addSubview(capBadge)
        card.addSubview(faveButton)
        card.addSubview(diningImage)
        card.addSubview(phoneIcon)
        card.addSubview(phoneLabel)
        card.addSubview(distIcon)
        card.addSubview(distLabel)
        card.addSubview(addressIcon)
        card.addSubview(addressLabel)
        card.addSubview(nameLabel)
        
        clockIcon.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        clockIcon.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        clockIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        clockIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let date = Date()
        openTimeLabel.text = "     "
        if let intervals = diningHall.weeklyHours?.hoursForWeekday(DayOfWeek.weekday(date)) {
            /*If dining hall has open hours for today, set the label to show the current
             or next open interval. If there are no open times in the rest of the day,
             set label to "Closed Today".*/
            openTimeLabel.text = "Closed Today"
            var nextOpenInterval: DateInterval? = nil
            for interval in intervals {
                if interval.contains(date) {
                    nextOpenInterval = nil
                    openTimeLabel.text = formatter.string(from: interval.start, to: interval.end)
                    break
                } else if date.compare(interval.start) == .orderedAscending {
                    if nextOpenInterval == nil {
                        nextOpenInterval = interval
                    } else if interval.compare(nextOpenInterval!) == .orderedAscending {
                        nextOpenInterval = interval
                    }
                }
            }
            if nextOpenInterval != nil {
                openTimeLabel.text = formatter.string(from: nextOpenInterval!.start, to: nextOpenInterval!.end)
            }
        }
        openTimeLabel.centerYAnchor.constraint(equalTo: clockIcon.centerYAnchor).isActive = true
        openTimeLabel.leftAnchor.constraint(equalTo: clockIcon.rightAnchor, constant: 5).isActive = true
        
        if diningHall.isOpen! {
            openTag.text = "Open"
            openTag.backgroundColor = Color.openTag
        } else {
            openTag.text = "Closed"
            openTag.backgroundColor = Color.closedTag
        }
        openTag.leftAnchor.constraint(equalTo: openTimeLabel.rightAnchor, constant: kViewMargin).isActive = true
        openTag.centerYAnchor.constraint(equalTo: clockIcon.centerYAnchor).isActive = true
        openTag.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        chairImage.centerYAnchor.constraint(equalTo: clockIcon.centerYAnchor).isActive = true
        chairImage.leftAnchor.constraint(equalTo: openTag.rightAnchor, constant: kViewMargin).isActive = true
        chairImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        chairImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        chairImage.contentMode = .scaleAspectFit
        
        //TODO: use actual capacity
        capBadge.text = "High"
        capBadge.backgroundColor = Color.highCapacityTag
        capBadge.leftAnchor.constraint(equalTo: chairImage.rightAnchor, constant: 5).isActive = true
        capBadge.centerYAnchor.constraint(equalTo: clockIcon.centerYAnchor).isActive = true
        capBadge.widthAnchor.constraint(equalToConstant: 50).isActive = true
        capBadge.rightAnchor.constraint(lessThanOrEqualTo: faveButton.leftAnchor, constant: -1 * kViewMargin).isActive = true
        
        if diningHall.isFavorited {
            faveButton.setImage(UIImage(named: "Gold Star"), for: .normal)
        } else {
            faveButton.setImage(UIImage(named: "Grey Star"), for: .normal)
        }
        faveButton.centerYAnchor.constraint(equalTo: clockIcon.centerYAnchor).isActive = true
        faveButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        faveButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        faveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        if diningHall.image != nil {
            diningImage.image = diningHall.image
        } else {
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: self.diningHall.imageURL!) else { return }
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.diningHall.image = image
                    self.diningImage.image = image
                }
            }
        }
        diningImage.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        diningImage.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        diningImage.bottomAnchor.constraint(equalTo: faveButton.topAnchor, constant: -1 * kViewMargin).isActive = true
        diningImage.widthAnchor.constraint(equalTo: diningImage.heightAnchor, multiplier: 1.3).isActive = true
        
        phoneIcon.bottomAnchor.constraint(equalTo: clockIcon.topAnchor, constant: -1 * kViewMargin).isActive = true
        phoneIcon.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        phoneIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        phoneIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        if diningHall.phoneNumber != nil {
            phoneLabel.text = diningHall.phoneNumber
        } else {
            phoneLabel.text = "     "
        }
        phoneLabel.centerYAnchor.constraint(equalTo: phoneIcon.centerYAnchor).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: phoneIcon.layoutMarginsGuide.rightAnchor, constant:  kViewMargin).isActive = true
        phoneLabel.rightAnchor.constraint(lessThanOrEqualTo: distIcon.leftAnchor, constant: -5).isActive = true
        
        distIcon.centerYAnchor.constraint(equalTo: phoneIcon.centerYAnchor).isActive = true
        distIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        distIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        /*Display location from user, or nothing if the user's location can't be
         determined or if the user is too far away.*/
        if location != nil {
            let dist = self.diningHall.getDistanceToUser(userLoc: location)
            if dist < DiningHall.invalidDistance {
                self.distLabel.text = String(dist) + " mi"
            } else {
                self.distLabel.text = "     "
            }
        } else {
            self.distLabel.text = "     "
        }
        
        distLabel.centerYAnchor.constraint(equalTo: distIcon.centerYAnchor).isActive = true
        distLabel.rightAnchor.constraint(equalTo: diningImage.leftAnchor, constant: -1 * kViewMargin).isActive = true
        distLabel.leftAnchor.constraint(equalTo: distIcon.rightAnchor, constant: 5).isActive = true
        distLabel.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        addressIcon.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        addressIcon.bottomAnchor.constraint(equalTo: phoneIcon.topAnchor, constant: -1 * kViewMargin).isActive = true
        addressIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        addressIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        //Get shortened version of address
        if let longAddress = diningHall.campusLocation {
            if let ind = longAddress.range(of: "Berkeley")?.upperBound {
                let newAdress = longAddress[..<ind]
                addressLabel.text = String(newAdress)
            } else {
                addressLabel.text = longAddress
            }
        } else {
            addressLabel.text = ""
        }
        addressLabel.leftAnchor.constraint(equalTo: addressIcon.rightAnchor, constant: 5).isActive = true
        addressLabel.centerYAnchor.constraint(equalTo: addressIcon.centerYAnchor).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: diningImage.leftAnchor, constant: -1 * kViewMargin).isActive = true
        
        nameLabel.text = diningHall.searchName
        nameLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: diningImage.leftAnchor, constant: -1 * kViewMargin).isActive = true
        nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: addressIcon.topAnchor, constant: -1 * kViewMargin).isActive = true
    }
    
    func setupMenuControl() {
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
        control.topAnchor.constraint(equalTo: card.bottomAnchor, constant: kViewMargin).isActive = true
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
    
    func setupMenu() {
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

extension DiningDetailViewController {
    
    @objc func toggleFave(sender: UIButton) {
        if diningHall.isFavorited {
            sender.setImage(UIImage(named: "Grey Star"), for: .normal)
            diningHall.isFavorited = false
        } else {
            sender.setImage(UIImage(named: "Gold Star"), for: .normal)
            diningHall.isFavorited = true
        }
    }
    
}

extension  DiningDetailViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation
        DispatchQueue.main.async {
            if self.diningHall != nil {
                let dist = self.diningHall.getDistanceToUser(userLoc: userLocation)
                self.distLabel.text = String(dist) + " mi"
                self.location = userLocation
            } else {
                self.distLabel.text = ""
            }
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
