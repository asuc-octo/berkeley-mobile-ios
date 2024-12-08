//
//  FitnessViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/21/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase
import SwiftUI

fileprivate let kHeaderFont: UIFont = BMFont.bold(24)
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16
fileprivate let kClassesHeight: CGFloat = 300
fileprivate let kClassesCollapsedHeight: CGFloat = 92

class FitnessViewController: UIViewController, SearchDrawerViewDelegate {

    // MARK: SearchDrawerViewDelegate

    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    // SearchDrawerViewDelegate property
    var mainContainer: MainContainerViewController?
    var pinDelegate: SearchResultsViewDelegate?

    // MARK: FitnessViewController

    private var scrollView: UIScrollView!
    private var content: UIView!
    
    private var classesCard: CardView!
    private var gymCard: CardView!
    
    private var showButton: UIButton!
    private var missingClassesView: MissingDataView!
    
    private var bClassesExpanded = false
    
    // For use in the "Classes" card
    private var classesTable: UITableView!
    // To display a list of gyms in the "Fitness Centers" card
    var filterTableView = FilterTableView<Gym>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    
    var gyms: [Gym] = []
    var futureClasses: [GymClass] = []
    
    private var classesController = GymClassesController()
    private var gymsController = GymsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        setupScrollView()
        setupClasses()
        setupGyms()
        
        // Update `filterTableView` when user location is updated.
        LocationManager.notificationCenter.addObserver(
            filterTableView,
            selector: #selector(filterTableView.update),
            name: .locationUpdated,
            object: nil
        )
        
        classesController.vc = self
        gymsController.vc = self
        
        // Fetch Gym Classes
        DataManager.shared.fetch(source: GymClassDataSource.self) { classes in
            let classes = classes as? [[GymClass]] ?? []
            // How the classes are sorted (start time, then alphabetical)
            let sortFn = { (lhs: GymClass, rhs: GymClass) -> Bool in
                lhs.date == rhs.date ? lhs.name < rhs.name :  lhs.date < rhs.date
            }
            
            self.futureClasses = classes.reduce([], +).sorted(by: sortFn)
            
            if (self.futureClasses.count == 0) {
                self.showButton.isHidden = true
                self.missingClassesView.isHidden = false
                self.classesCard.setHeightConstraint(kClassesCollapsedHeight)
            }
            
            self.classesTable.reloadData()
            self.scrollView.layoutSubviews()
            self.viewDidLayoutSubviews()
        }
        
        // fetch gyms and fetch occupancy data afterwards
        DataManager.shared.fetch(source: GymDataSource.self) { gyms in
            self.gyms = gyms as? [Gym] ?? []
            self.filterTableView.setData(data: gyms as! [Gym])
            self.filterTableView.update()
            DataManager.shared.fetch(source: OccupancyDataSource.self) {_ in
                DispatchQueue.main.async {
                    self.filterTableView.update()
                }
            }
        }
    }
    
    @objc func willExpandClasses() {
        UIView.animate(withDuration: 0.2) {
            if !self.bClassesExpanded {
                self.classesCard.heightConstraint?.constant = self.view.frame.height
                self.classesCard.heightConstraint?.constant -=  self.view.layoutMargins.top + self.view.layoutMargins.bottom
            } else {
                self.classesCard.heightConstraint?.constant = kClassesHeight
            }
            self.bClassesExpanded = !self.bClassesExpanded
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.classesCard.frame.minY)
            self.scrollView.contentOffset.y -= self.view.layoutMargins.top
            self.view.layoutIfNeeded()
            self.viewDidLayoutSubviews()
        }
    }
    
}

// MARK: - View

extension FitnessViewController {
    
    // ScrollView
    func setupScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setConstraintsToView(top: view, bottom: view, left: view, right: view)
        scrollView.showsVerticalScrollIndicator = false
        
        content = UIView()
        scrollView.addSubview(content)
        content.layoutMargins = view.layoutMargins
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = gymCard.frame.maxY + view.layoutMargins.bottom
    }
    
    // Upcoming Classes
    func setupClasses() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: content.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: kClassesHeight).isActive = true
        
        let occupancyView = UIHostingController(rootView: OccupancyView()).view!
        
        occupancyView.translatesAutoresizingMaskIntoConstraints = false
        occupancyView.layer.cornerRadius = 12
        occupancyView.clipsToBounds = true
        scrollView.addSubview(occupancyView)
        
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: content.layoutMarginsGuide.topAnchor),
            card.leftAnchor.constraint(equalTo: content.layoutMarginsGuide.leftAnchor),
            card.heightAnchor.constraint(equalToConstant: kClassesHeight),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6, constant: -8),

            occupancyView.topAnchor.constraint(equalTo: card.topAnchor),
            occupancyView.leftAnchor.constraint(equalTo: card.rightAnchor, constant: 8),
                    occupancyView.rightAnchor.constraint(equalTo: content.layoutMarginsGuide.rightAnchor),
                    occupancyView.heightAnchor.constraint(equalTo: card.heightAnchor)
        ])
        
        
        
        let headerLabel = UILabel()
        headerLabel.font = kHeaderFont
        headerLabel.text = "Classes"
        card.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        
        let scheduleButton = UIButton()
        scheduleButton.setTitle("See Full Schedule >", for: .normal)
        scheduleButton.titleLabel?.font = BMFont.light(12)
        scheduleButton.setTitleColor(BMColor.primaryText, for: .normal)
        // TODO: Set color
        scheduleButton.setTitleColor(.black, for: .highlighted)
        scheduleButton.addTarget(self, action: #selector(willExpandClasses), for: .touchUpInside)
        card.addSubview(scheduleButton)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor).isActive = true
        scheduleButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        scheduleButton.leftAnchor.constraint(greaterThanOrEqualTo: headerLabel.rightAnchor, constant: 5).isActive = true
        
        classesTable = UITableView()
        classesTable.separatorStyle = .none
        classesTable.showsVerticalScrollIndicator = false
        classesTable.rowHeight = EventTableViewCell.kCellHeight
        classesTable.backgroundColor = UIColor.clear
        classesTable.dataSource = classesController
        classesTable.delegate = classesController
        classesTable.register(EventTableViewCell.self, forCellReuseIdentifier: GymClassesController.kCellIdentifier)
        card.addSubview(classesTable)
        classesTable.translatesAutoresizingMaskIntoConstraints = false
        classesTable.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: kViewMargin).isActive = true
        classesTable.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        classesTable.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        classesTable.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
                
        classesCard = card
        showButton = scheduleButton
        missingClassesView = MissingDataView(parentView: classesTable, text: "No classes found")
    }
    
    // Gyms
    func setupGyms() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: classesCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor).isActive = true
        gymCard = card
        
        let fitnessLabel = UILabel()
        fitnessLabel.text = "Fitness Locations"
        fitnessLabel.font = kHeaderFont
        fitnessLabel.adjustsFontSizeToFitWidth = true
        card.addSubview(fitnessLabel)
        
        setupFilterTableView()
        card.addSubview(filterTableView)
        
        fitnessLabel.translatesAutoresizingMaskIntoConstraints = false
        fitnessLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        fitnessLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        fitnessLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        filterTableView.topAnchor.constraint(equalTo: fitnessLabel.layoutMarginsGuide.bottomAnchor, constant: kViewMargin).isActive = true
        filterTableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        filterTableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func setupFilterTableView() {
        let functions: [TableFunction] = [
            Sort<Gym>(label: "Nearby", sort: Gym.locationComparator()),
            Filter<Gym>(label: "Open", filter: {gym in gym.isOpen ?? false}),
        ]
        filterTableView = FilterTableView<Gym>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortAlph(item1:item2:), initialSelectedIndices: [0])
        self.filterTableView.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.kCellIdentifier)
        self.filterTableView.tableView.dataSource = gymsController
        self.filterTableView.tableView.delegate = gymsController
    }
    
}

// MARK: - Analytics

extension FitnessViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_gym_screen", parameters: nil)
    }
}
