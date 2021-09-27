//
//  DiningViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

class DiningViewController: UIViewController, SearchDrawerViewDelegate {
    
    private var filterTableView: FilterTableView = FilterTableView<DiningLocation>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    private var diningLocations: [DiningLocation] = []
    
    private var headerLabel: UILabel!
    private var diningCard: CardView!
    
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    // SearchDrawerViewDelegate property
    var mainContainer: MainContainerViewController?
    var pinDelegate: SearchResultsViewDelegate?
    
    let diningImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Dining")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        setupCardView()
        
        // Update `filterTableView` when user location is updated.
        LocationManager.notificationCenter.addObserver(
            filterTableView,
            selector: #selector(filterTableView.update),
            name: .locationUpdated,
            object: nil
        )
        
        // fetch dining hall and cafe data, make sure occupancy data has been fetched after each one is complete
        DataManager.shared.fetch(source: DiningHallDataSource.self) { diningLocations in
            self.diningLocations.append(contentsOf: diningLocations as? [DiningLocation] ?? [])
            self.filterTableView.setData(data: self.diningLocations)
            self.filterTableView.update()
            DataManager.shared.fetch(source: OccupancyDataSource.self) {_ in
                DispatchQueue.main.async {
                    self.filterTableView.update()
                }
            }
        }
    }
}

// MARK: TableView Delegate and Data Source

extension DiningViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath) as? FilterTableViewCell {
            if let diningHall: DiningLocation = self.filterTableView.filteredData[safe: indexPath.row] {
                cell.updateContents(item: diningHall)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dropPin(item: self.filterTableView.filteredData[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: View

extension DiningViewController {
    // General card page
    func setupCardView() {
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let header = UILabel()
        header.text = "Find a place to dine"
        header.font = Font.bold(24)
        header.adjustsFontSizeToFitWidth = true
        header.textColor = Color.blackText
        card.addSubview(header)
        
        card.addSubview(diningImage)
        diningImage.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        diningImage.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        diningImage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        diningImage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: diningImage.rightAnchor, constant: 15).isActive = true
        header.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        setupTableView()
        card.addSubview(filterTableView)
        
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        filterTableView.topAnchor.constraint(equalTo: header.layoutMarginsGuide.bottomAnchor, constant: 16).isActive = true
        filterTableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        filterTableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        
        diningCard = card
        headerLabel = header
    }
    
    // Table of dining locations
    func setupTableView() {
        let functions: [TableFunction] = [
            Sort<DiningLocation>(label: "Nearby", sort: DiningHall.locationComparator()),
            Filter<DiningLocation>(label: "Open", filter: {diningHall in diningHall.isOpen ?? false}),
        ]
        filterTableView = FilterTableView<DiningLocation>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortAlph(item1:item2:), initialSelectedIndices: [0])
        self.filterTableView.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.kCellIdentifier)
        self.filterTableView.tableView.dataSource = self
        self.filterTableView.tableView.delegate = self
    }
}

// MARK: - Analytics

extension DiningViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_food_screen", parameters: nil)
    }
}
