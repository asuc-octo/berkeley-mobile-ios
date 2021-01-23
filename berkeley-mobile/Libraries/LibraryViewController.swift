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
    
    // MARK: DrawerViewDelegate
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    // MARK: SearchDrawerViewDelegate
    var mainContainer: MainContainerViewController?
    
    var filterTableView: FilterTableView = FilterTableView<Library>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    var safeArea: UILayoutGuide!
    var libraries: [Library] = []
    
    private var scrollView: UIScrollView!
    private var content: UIView!
    
    var studyPactCard: CardView = CardView()
    let studyPactContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var studyGroupsGrid: StudyGroupsView?
    let allButton: UIButton = UIButton()
    
    private var libraryCard: CardView!
    
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
        setUpScrollView()
        setUpStudyPactCard()
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("awoenfioawnef")
        print(scrollView.frame)
        print(libraryCard.frame.maxY + view.layoutMargins.bottom)
        scrollView.contentSize.height = libraryCard.frame.maxY + view.layoutMargins.bottom
    }
    
    func setUpScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setConstraintsToView(top: view, bottom: view, left: view, right: view)
        scrollView.showsVerticalScrollIndicator = false
        
        content = UIView()
        scrollView.addSubview(content)
        content.layoutMargins = view.layoutMargins
    }
    
    func setUpStudyPactCard() {
        studyPactCard = CardView()
        studyPactCard.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        scrollView.addSubview(studyPactCard)
        studyPactCard.translatesAutoresizingMaskIntoConstraints = false
        studyPactCard.topAnchor.constraint(equalTo: content.layoutMarginsGuide.topAnchor).isActive = true
        studyPactCard.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        studyPactCard.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        studyPactCard.heightAnchor.constraint(equalToConstant: 185).isActive = true
        
        let studyGroupsLabel = UILabel()
        studyGroupsLabel.text = "Your Study Groups"
        studyGroupsLabel.font = Font.bold(24)
        studyGroupsLabel.adjustsFontSizeToFitWidth = true
        studyGroupsLabel.textColor = Color.blackText
        studyPactCard.addSubview(studyGroupsLabel)
        studyGroupsLabel.translatesAutoresizingMaskIntoConstraints = false
        studyGroupsLabel.leftAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.leftAnchor).isActive = true
        studyGroupsLabel.topAnchor.constraint(equalTo: studyPactCard.layoutMarginsGuide.topAnchor).isActive = true
        
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
    
    // TODO: remove
    func getDummyGroups() -> [StudyGroup] {
        let person0 = StudyGroupMember(profilePictureURL: URL(string: "https://images.generated.photos/hApOLywddgHrBNt5NWqIFViI1dJNQ7oev8TKAfmsuGE/rs:fit:256:256/Z3M6Ly9nZW5lcmF0/ZWQtcGhvdG9zL3Yz/XzA0NzY1MjkuanBn.jpg"), name: "Jack Doe", email: "jack.doe@berkeley.edu", phoneNumber: "0000000000")
        let person1 = StudyGroupMember(profilePictureURL: URL(string: "https://images.generated.photos/t6rnO4g54jflMAk-nLFAulAayL4MkTkajbuHAOJEs9w/rs:fit:256:256/Z3M6Ly9nZW5lcmF0/ZWQtcGhvdG9zL3Yy/XzA0NTkxODQuanBn.jpg"), name: "Jill Doe", email: "jill.doe@berkeley.edu", phoneNumber: "1111111111")
        let person2 = StudyGroupMember(profilePictureURL: URL(string:  "https://images.generated.photos/UnBJAeCfIR180b3sQ1G9opucAnwafc8DErx5YXRjT6I/rs:fit:256:256/Z3M6Ly9nZW5lcmF0/ZWQtcGhvdG9zL3Yy/XzA0NDU1NjMuanBn.jpg"), name: "Jane Doe", email: "jane.doe@berkeley.edu", phoneNumber: "2222222222")
        let person3 = StudyGroupMember(profilePictureURL: URL(string: "https://images.generated.photos/f1utkmrXZQ_CU7ixY-qNL2Creb0MnE9Np4FpuXq_yoQ/rs:fit:256:256/Z3M6Ly9nZW5lcmF0/ZWQtcGhvdG9zL3Yz/XzA4OTc1NTguanBn.jpg"), name: "Bob Jones", email: "bob.jones@berkeley.edu", phoneNumber: "3333333333")
        let person4 = StudyGroupMember(profilePictureURL: nil, name: "A B", email: "a.b@berkeley.edu", phoneNumber: "4444444444")
        let group0 = StudyGroup(className: "CS 170", groupMembers: [person0, person1, person2, person3], collaborative: true, virtual: true, pending: false, preferredNumberMembers: 4)
        let group1 = StudyGroup(className: "ECON 100A", groupMembers: [person0, person1, person2, person3, person4, person3], collaborative: false, virtual: true, pending: false, preferredNumberMembers: 6)
        let group2 = StudyGroup(className: "STAT 140", groupMembers: [person0], collaborative: true, virtual: false, pending: false, preferredNumberMembers: 1)
        let group3 = StudyGroup(className: "CS 188", groupMembers: [person2, person3], collaborative: false, virtual: false, pending: false, preferredNumberMembers: 2)
        let group4 = StudyGroup(className: "IEOR 142", groupMembers: [], collaborative: false, virtual: false, pending: true, preferredNumberMembers: 3)
        let group5 = StudyGroup(className: "ECON 100A", groupMembers: [person0, person4, person2, person0, person4], collaborative: false, virtual: true, pending: false, preferredNumberMembers: 5)
        return [group0, group1, group2, group3, group4, group5, group0, group1, group2, group3, group4, group5]
    }
    
    func refreshStudyGroupContents() {
        // TODO: once auth/profile is done set to use actual value. using time to test both forms
        let date = Date()
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: date)
        let loggedIn = seconds % 2 == 1
        
        if loggedIn {
            // TODO: get actual study groups
            allButton.isHidden = false
            
            let groups = getDummyGroups()
            let usedGroups = Array(groups.prefix(2))
            if let grid = studyGroupsGrid {
                grid.refreshGroups()
            } else {
                for view in studyPactContent.subviews {
                    view.removeFromSuperview()
                }
                let groupGrid = StudyGroupsView(studyGroups: usedGroups, includeCreateGroup: groups.count < 2)
                studyPactContent.addSubview(groupGrid)
                groupGrid.translatesAutoresizingMaskIntoConstraints = false
                groupGrid.topAnchor.constraint(equalTo: studyPactContent.topAnchor).isActive = true
                groupGrid.bottomAnchor.constraint(equalTo: studyPactContent.bottomAnchor).isActive = true
                groupGrid.rightAnchor.constraint(equalTo: studyPactContent.rightAnchor).isActive = true
                groupGrid.leftAnchor.constraint(equalTo: studyPactContent.leftAnchor).isActive = true
                studyGroupsGrid = groupGrid
            }
        } else {
            allButton.isHidden = true
            
            if studyGroupsGrid != nil {
                for view in studyPactContent.subviews {
                    view.removeFromSuperview()
                }
                studyGroupsGrid = nil
            }
            if studyPactContent.subviews.count == 0 {
                let profileButton = ActionButton(title: "Sign In to Get Started")
                profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
                studyPactContent.addSubview(profileButton)
                profileButton.translatesAutoresizingMaskIntoConstraints = false
                profileButton.centerYAnchor.constraint(equalTo: studyPactContent.centerYAnchor).isActive = true
                profileButton.rightAnchor.constraint(equalTo: studyPactContent.rightAnchor).isActive = true
                profileButton.leftAnchor.constraint(equalTo: studyPactContent.leftAnchor).isActive = true
            }
        }
    }
    
    @objc func goToAllStudyGroups() {
        let vc = AllStudyGroupsViewController()
        vc.studyGroups = getDummyGroups()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func goToProfile() {
        if let tabBarController = UIApplication.shared.windows.first!.rootViewController as? TabBarController {
            tabBarController.selectProfileTab()
        }
    }
    
    func setUpTableView() {
        //general setup and constraints
        let card = CardView()
        libraryCard = card
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: studyPactCard.bottomAnchor, constant: kViewMargin).isActive = true
        card.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor).isActive = true
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
