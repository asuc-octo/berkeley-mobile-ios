//
//  DiningViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Firebase
import UIKit
import SwiftUI

// MARK: - DiningView

struct DiningView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DiningViewController
    
    private let mapViewController: MapViewController
    
    init(mapViewController: MapViewController) {
        self.mapViewController = mapViewController
    }
    
    func makeUIViewController(context: Context) -> DiningViewController {
        return DiningViewController(mapViewController: mapViewController)
    }
    
    func updateUIViewController(_ uiViewController: DiningViewController, context: Context) {}
}


// MARK: - DiningViewController

class DiningViewController: UIViewController, SearchDrawerViewDelegate {
    
    private var filterTableView: FilterTableView = FilterTableView<DiningLocation>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortClose(loc1:loc2:))
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
        img.image = UIImage(named: "Dining")?.colored(BMColor.blackText)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    init(mapViewController: MapViewController) {
        pinDelegate = mapViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCardView()
        
        // Update `filterTableView` when user location is updated.
        LocationManager.notificationCenter.addObserver(
            filterTableView,
            selector: #selector(filterTableView.update),
            name: .locationUpdated,
            object: nil
        )
        
        // Fetch dining hall and cafe data, make sure occupancy data has been fetched after each one is complete
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
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath)
        let diningHall = self.filterTableView.filteredData[indexPath.row]
        
        let cellViewModel = HomeSectionListRowViewModel()
        cellViewModel.configureRow(with: diningHall)
        
        cell.contentConfiguration = UIHostingConfiguration {
            HomeSectionListRowView()
                .environmentObject(cellViewModel)
        }
        return cell
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
    func setupCardView() {
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -75).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let header = UILabel()
        header.text = "Find a place to dine"
        header.font = BMFont.bold(24)
        header.adjustsFontSizeToFitWidth = true
        header.textColor = BMColor.blackText
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
    
    func setupTableView() {
        let functions: [TableFunction] = [
            Sort<DiningLocation>(label: "Nearby", sort: DiningHall.locationComparator()),
            Filter<DiningLocation>(label: "Open", filter: {diningHall in diningHall.isOpen ?? false}),
        ]
        filterTableView = FilterTableView<DiningLocation>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortClose(loc1:loc2:))
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
