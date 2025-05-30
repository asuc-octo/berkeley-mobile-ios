//
//  FitnessViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/21/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Firebase
import UIKit
import SwiftUI
import WidgetKit

// MARK: - FitnessView

struct FitnessView: UIViewControllerRepresentable {
    typealias UIViewControllerType = FitnessViewController
    
    private let mapViewController: MapViewController
    
    init(mapViewController: MapViewController) {
        self.mapViewController = mapViewController
    }
    
    func makeUIViewController(context: Context) -> FitnessViewController {
        FitnessViewController(mapViewController: mapViewController)
    }
    
    func updateUIViewController(_ uiViewController: FitnessViewController, context: Context) {}
}


// MARK: - FitnessViewController

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
    
    private var RSFCard: CardView!
    private var CMSCard: CardView!
    private var classesCard: CardView!
    private var gymCard: CardView!
    private var missingClassesView: MissingDataView!
    
    private var bClassesExpanded = false
    
    // To display a list of gyms in the "Fitness Centers" card
    var filterTableView = FilterTableView<Gym>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortClose(loc1:loc2:))
    var gyms: [Gym] = []
    
    private var gymsController = GymsController()
    private var mapViewController: MapViewController!
    
    init(mapViewController: MapViewController) {
        pinDelegate = mapViewController
        self.mapViewController = mapViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupRSFGymOccupancyCard()
        setupCMSGymOccupancyCard()
        setupGyms()
        
        // Update `filterTableView` when user location is updated.
        BMLocationManager.notificationCenter.addObserver(
            filterTableView,
            selector: #selector(filterTableView.update),
            name: .locationUpdated,
            object: nil
        )
        
        gymsController.vc = self
        
        // Fetch gyms data afterwards
        DataManager.shared.fetch(source: GymDataSource.self) { gyms in
            self.gyms = gyms as? [Gym] ?? []
            self.filterTableView.setData(data: gyms as! [Gym])
            self.filterTableView.update()
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "GymOccupancyWidget")
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
    
    func setupRSFGymOccupancyCard() {
        guard let homeViewModel = mapViewController.homeViewModel else {
            return
        }
        
        let RSFCard = CardView()
        RSFCard.layoutMargins = kCardPadding
        RSFCard.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(RSFCard)
        self.RSFCard = RSFCard
        
        let RSFView = UIHostingController(rootView: GymOccupancyView().environmentObject(homeViewModel.rsfOccupancyViewModel)).view!
        RSFView.translatesAutoresizingMaskIntoConstraints = false
        RSFView.layer.cornerRadius = 12
        RSFView.backgroundColor = UIColor.clear
        RSFCard.addSubview(RSFView)

        NSLayoutConstraint.activate([
            RSFCard.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            RSFCard.widthAnchor.constraint(equalToConstant: kClassesCollapsedHeight),
            RSFCard.heightAnchor.constraint(equalToConstant: kClassesCollapsedHeight),
            RSFCard.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            RSFView.topAnchor.constraint(equalTo: RSFCard.topAnchor),
            RSFView.leadingAnchor.constraint(equalTo: RSFCard.leadingAnchor),
            RSFView.trailingAnchor.constraint(equalTo: RSFCard.trailingAnchor),
            RSFView.bottomAnchor.constraint(equalTo: RSFCard.bottomAnchor)
        ])
    }
    
    func setupCMSGymOccupancyCard() {
        guard let homeViewModel = mapViewController.homeViewModel else {
            return
        }
        
        let CMSCard = CardView()
        CMSCard.layoutMargins = kCardPadding
        CMSCard.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(CMSCard)
        
        let CMSView = UIHostingController(rootView: GymOccupancyView().environmentObject(homeViewModel.stadiumOccupancyViewModel)).view!
        CMSView.translatesAutoresizingMaskIntoConstraints = false
        CMSView.layer.cornerRadius = 12
        CMSView.backgroundColor = UIColor.clear
        CMSCard.addSubview(CMSView)

        NSLayoutConstraint.activate([
            RSFCard.trailingAnchor.constraint(equalTo: CMSCard.leadingAnchor, constant: -15),
            
            CMSCard.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            CMSCard.widthAnchor.constraint(equalToConstant: kClassesCollapsedHeight),
            CMSCard.heightAnchor.constraint(equalToConstant: kClassesCollapsedHeight),
            
            CMSView.topAnchor.constraint(equalTo: CMSCard.topAnchor),
            CMSView.leadingAnchor.constraint(equalTo: CMSCard.leadingAnchor),
            CMSView.trailingAnchor.constraint(equalTo: CMSCard.trailingAnchor),
            CMSView.bottomAnchor.constraint(equalTo: CMSCard.bottomAnchor)
        ])
    }
    
    // Gyms
    func setupGyms() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: RSFCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -75).isActive = true
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
        filterTableView = FilterTableView<Gym>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortClose(loc1:loc2:))
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
