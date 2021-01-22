//
//  LibraryViewController.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchDrawerViewDelegate {
    
    // DrawerViewDelegate properties
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    // SearchDrawerViewDelegate property
    var mainContainer: MainContainerViewController?
    
    var filterTableView: FilterTableView = FilterTableView<Library>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    var safeArea: UILayoutGuide!
    var libraries: [Library] = []
    
    var studyPactCard: CardView = CardView()
    let studyPactContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var showingStudyGroups: Bool?
    
    let bookImage:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Book")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update `filterTableView` when user location is updated.
        LocationManager.notificationCenter.addObserver(
            filterTableView,
            selector: #selector(filterTableView.update),
            name: .locationUpdated,
            object: nil
        )
      
        // fetch libraries and fetch occupancy data afterwards
        DataManager.shared.fetch(source: LibraryDataSource.self) { libraries in
            self.libraries = libraries as? [Library] ?? []
            self.filterTableView.setData(data: libraries as! [Library])
            self.filterTableView.update()
            DataManager.shared.fetch(source: OccupancyDataSource.self) {_ in
                DispatchQueue.main.async {
                    self.filterTableView.update()
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        //removes separator lines
        safeArea = view.layoutMarginsGuide
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        setUpStudyPactCard()
        setUpTableView()
    }
    
    func setUpStudyPactCard() {
        studyPactCard = CardView()
        studyPactCard.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        view.addSubview(studyPactCard)
        studyPactCard.translatesAutoresizingMaskIntoConstraints = false
        studyPactCard.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        studyPactCard.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        studyPactCard.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        studyPactCard.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        let studyGroupsLabel = UILabel()
        studyGroupsLabel.text = "Your Study Groups"
        studyGroupsLabel.font = Font.bold(24)
        studyGroupsLabel.adjustsFontSizeToFitWidth = true
        studyGroupsLabel.textColor = Color.blackText
        studyPactCard.addSubview(studyGroupsLabel)
        studyGroupsLabel.translatesAutoresizingMaskIntoConstraints = false
        studyGroupsLabel.leftAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.leftAnchor).isActive = true
        studyGroupsLabel.topAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.topAnchor).isActive = true
        
        let allButton = UIButton()
        allButton.setTitle("See All >", for: .normal)
        allButton.titleLabel?.font = Font.light(12)
        allButton.setTitleColor(Color.primaryText, for: .normal)
        allButton.setTitleColor(.black, for: .highlighted)
        allButton.addTarget(self, action: #selector(goToAllStudyGroups), for: .touchUpInside)
        studyPactCard.addSubview(allButton)
        allButton.translatesAutoresizingMaskIntoConstraints = false
        allButton.centerYAnchor.constraint(equalTo: studyGroupsLabel.centerYAnchor).isActive = true
        allButton.rightAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.rightAnchor).isActive = true
        allButton.leftAnchor.constraint(greaterThanOrEqualTo: studyGroupsLabel.rightAnchor, constant: 5).isActive = true
        
        studyPactCard.addSubview(studyPactContent)
        studyPactContent.topAnchor.constraint(equalTo: studyGroupsLabel.bottomAnchor, constant: 12).isActive = true
        studyPactContent.rightAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.rightAnchor).isActive = true
        studyPactContent.leftAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.leftAnchor).isActive = true
        studyPactContent.bottomAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.bottomAnchor).isActive = true
        refreshStudyGroupContents()
    }
    
    func refreshStudyGroupContents() {
        // TODO: once auth/profile is done set to use actual value
        let date = Date()
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: date)
        let profileComplete = seconds % 2 == 1
        
        if profileComplete {
            if let showing = showingStudyGroups, showing {
                // refresh gridview
            } else {
                for view in studyPactContent.subviews {
                    view.removeFromSuperview()
                }
                
            }
            showingStudyGroups = true
        } else {
            let addButton = !(showingStudyGroups ?? true)
            if addButton {
                for view in studyPactContent.subviews {
                    view.removeFromSuperview()
                }
                let profileButton = UIButton()
                profileButton.setTitle("Set up your profile to join a study group >", for: .normal)
                profileButton.titleLabel?.lineBreakMode = .byWordWrapping
                profileButton.titleLabel?.font = Font.regular(16)
                profileButton.titleLabel?.textAlignment = .left
                profileButton.setTitleColor(Color.primaryText, for: .normal)
                profileButton.setTitleColor(.black, for: .highlighted)
                
                profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
                studyPactContent.addSubview(profileButton)
                profileButton.translatesAutoresizingMaskIntoConstraints = false
                profileButton.centerYAnchor.constraint(equalTo: studyPactContent.centerYAnchor).isActive = true
                profileButton.rightAnchor.constraint(equalTo: studyPactContent.rightAnchor).isActive = true
                profileButton.leftAnchor.constraint(equalTo: studyPactContent.leftAnchor).isActive = true
            }
            showingStudyGroups = false
        }
    }
    
    @objc func goToAllStudyGroups() {
        
    }
    
    @objc func goToProfile() {
        if let tabBarController = UIApplication.shared.windows.first!.rootViewController as? TabBarController {
            tabBarController.selectProfileTab()
        }
    }
    
    func setUpTableView() {
        //general setup and constraints
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: studyPactCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let studyLabel = UILabel()
        studyLabel.text = "Find your study spot"
        studyLabel.font = Font.bold(24)
        studyLabel.adjustsFontSizeToFitWidth = true
        studyLabel.textColor = Color.blackText
        card.addSubview(studyLabel)
        
        card.addSubview(bookImage)
        bookImage.centerYAnchor.constraint(equalTo: studyLabel.centerYAnchor).isActive = true
        bookImage.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        bookImage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        bookImage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        studyLabel.translatesAutoresizingMaskIntoConstraints = false
        studyLabel.leftAnchor.constraint(equalTo: bookImage.rightAnchor, constant: 15).isActive = true
        studyLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        studyLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        
        setupFilterTableView()
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(filterTableView)
        self.filterTableView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        self.filterTableView.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        self.filterTableView.topAnchor.constraint(equalTo: studyLabel.layoutMarginsGuide.bottomAnchor, constant: kViewMargin).isActive = true
        self.filterTableView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func setupFilterTableView() {
        let functions: [TableFunction] = [
            Sort<Library>(label: "Nearby", sort: Library.locationComparator()),
            Filter<Library>(label: "Open", filter: {lib in lib.isOpen ?? false}),
        ]
        filterTableView = FilterTableView<Library>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortAlph(item1:item2:), initialSelectedIndices: [0])
        self.filterTableView.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.kCellIdentifier)
        self.filterTableView.tableView.dataSource = self
        self.filterTableView.tableView.delegate = self

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentDetail(type: Library.self, item: self.filterTableView.filteredData[indexPath.row], containingVC: mainContainer!, position: .full)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //number of rows to be shown in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterTableView.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.kCellIdentifier, for: indexPath) as? FilterTableViewCell {
            if let lib: Library = self.filterTableView.filteredData[safe: indexPath.row] {
                cell.updateContents(item: lib)
                return cell
            }
        }
        return UITableViewCell()
    }
}

// MARK: - Analytics

extension LibraryViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_library_screen", parameters: nil)
        
        refreshStudyGroupContents()
    }
}
