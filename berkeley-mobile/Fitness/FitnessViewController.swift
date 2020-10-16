//
//  FitnessViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/21/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

fileprivate let kHeaderFont: UIFont = Font.bold(24)
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16
fileprivate let kTodayClassesHeight: CGFloat = 300
fileprivate let kTodayClassesCollapsedHeight: CGFloat = 92
fileprivate let kUpcomingCollapsedHeight: CGFloat = 16  // Same as TableView 0 elements

class FitnessViewController: UIViewController, SearchDrawerViewDelegate {

    // MARK: SearchDrawerViewDelegate

    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    // SearchDrawerViewDelegate property
    var mainContainer: MainContainerViewController?

    // MARK: FitnessViewController

    private var scrollView: UIScrollView!
    private var content: UIView!
    
    private var upcomingCard: CardView!
    private var todayCard: CardView!
    private var gymCard: CardView!
    
    private var showButton: UIButton!
    private var missingClassesView: MissingDataView!
    private var missingUpcomingView: MissingDataView!
    
    private var bClassesExpanded = false
    
    // For use in the "Today" card
    private var classesTable: UITableView!
    // For use in the "Upcoming" card
    private var classesCollection: CardCollectionView!
    // To display a list of gyms in the "Fitness Centers" card
    var filterTableView = FilterTableView<Gym>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    
    var gyms: [Gym] = []
    var upcomingClasses: [GymClass] = []
    var todayClasses: [GymClass] = []
    
    private var classesController = GymClassesController()
    private var gymsController = GymsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        setupScrollView()
        setupUpcomingClasses()
        setupTodayClasses()
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
            
            self.todayClasses = classes.filter { (classes) -> Bool in
                guard let start = classes.first?.date else { return false }
                return Calendar.current.isDateInToday(start)
            }.first?.sorted(by: sortFn) ?? []
            self.upcomingClasses = classes.reduce([], +).sorted(by: sortFn)
            
            if (self.upcomingClasses.count == 0) {
                self.missingUpcomingView.isHidden = false
                self.classesCollection.setHeightConstraint(kUpcomingCollapsedHeight)
            }
            
            if (self.todayClasses.count == 0) {
                self.showButton.isHidden = true
                self.missingClassesView.isHidden = false
                self.todayCard.setHeightConstraint(kTodayClassesCollapsedHeight)
            }
            
            self.classesTable.reloadData()
            self.classesCollection.reloadData()
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
                self.todayCard.heightConstraint?.constant = self.view.frame.height
                self.todayCard.heightConstraint?.constant -=  self.view.layoutMargins.top + self.view.layoutMargins.bottom
            } else {
                self.todayCard.heightConstraint?.constant = kTodayClassesHeight
            }
            self.bClassesExpanded = !self.bClassesExpanded
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.todayCard.frame.minY)
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
    func setupUpcomingClasses() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: content.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let contentView = UIView()
        contentView.layer.masksToBounds = true
        card.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setConstraintsToView(top: card, bottom: card, left: card, right: card)
        
        let headerLabel = UILabel()
        headerLabel.font = kHeaderFont
        headerLabel.text = "Upcoming"
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let collectionView = CardCollectionView(frame: .zero)
        collectionView.dataSource = classesController
        collectionView.contentInset = UIEdgeInsets(top: 0, left: card.layoutMargins.left, bottom: 0, right: card.layoutMargins.right)
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: kViewMargin).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: CardCollectionViewCell.kCardSize.height).isActive = true
        collectionView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        
        collectionView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        upcomingCard = card
        classesCollection = collectionView
        
        missingUpcomingView = MissingDataView(parentView: collectionView, text: "No upcoming classes")
    }
    
    // Upcoming Classes
    func setupTodayClasses() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: kTodayClassesHeight).isActive = true
        
        let headerLabel = UILabel()
        headerLabel.font = kHeaderFont
        headerLabel.text = "Today"
        card.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        
        let scheduleButton = UIButton()
        scheduleButton.setTitle("See Full Schedule >", for: .normal)
        scheduleButton.titleLabel?.font = Font.light(12)
        scheduleButton.setTitleColor(Color.primaryText, for: .normal)
        // TODO: Set color
        scheduleButton.setTitleColor(.black, for: .highlighted)
        scheduleButton.addTarget(self, action: #selector(willExpandClasses), for: .touchUpInside)
        card.addSubview(scheduleButton)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor).isActive = true
        scheduleButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        scheduleButton.leftAnchor.constraint(greaterThanOrEqualTo: headerLabel.rightAnchor, constant: 5).isActive = true
        
        classesTable = UITableView()
        classesTable.allowsSelection = false
        classesTable.separatorStyle = .none
        classesTable.showsVerticalScrollIndicator = false
        classesTable.rowHeight = EventTableViewCell.kCellHeight
        classesTable.dataSource = classesController
        classesTable.register(EventTableViewCell.self, forCellReuseIdentifier: GymClassesController.kCellIdentifier)
        card.addSubview(classesTable)
        classesTable.translatesAutoresizingMaskIntoConstraints = false
        classesTable.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: kViewMargin).isActive = true
        classesTable.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        classesTable.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        classesTable.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
                
        todayCard = card
        showButton = scheduleButton
        missingClassesView = MissingDataView(parentView: classesTable, text: "No classes found")
    }
    
    // Gyms
    func setupGyms() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: todayCard.bottomAnchor, constant: kViewMargin).isActive = true
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
