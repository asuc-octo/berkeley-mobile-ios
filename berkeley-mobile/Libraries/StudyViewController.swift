//
//  StudyViewController.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

class StudyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchDrawerViewDelegate {
    
    // MARK: DrawerViewDelegate
    var drawerViewController: DrawerViewController?
    var initialDrawerCenter = CGPoint()
    var initialGestureTranslation: CGPoint = CGPoint()
    var drawerStatePositions: [DrawerState : CGFloat] = [:]
    
    // MARK: SearchDrawerViewDelegate
    var mainContainer: MainContainerViewController?
    var pinDelegate: SearchResultsViewDelegate?
    
    // MARK: Setup
    private var scrollView: UIScrollView!
    private var content: UIView!
    private var bookImageView: UIImageView!
    
    private var bookIcon: UIImage? {
        UIImage(named: "Book")?.colored(BMColor.blackText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update `filterTableView` when user location is updated.
        LocationManager.notificationCenter.addObserver(
            filterTableView,
            selector: #selector(filterTableView.update),
            name: .locationUpdated,
            object: nil
        )
      
        // fetch libraries 
        DataManager.shared.fetch(source: LibraryDataSource.self) { libraries in
            self.libraries = libraries as? [Library] ?? []
            self.filterTableView.setData(data: libraries as! [Library])
            self.filterTableView.update()
        }
    }
    
    override func loadView() {
        super.loadView()
        safeArea = view.layoutMarginsGuide
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        setUpScrollView()
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = libraryCard.frame.maxY + view.layoutMargins.bottom
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bookImageView.image = bookIcon
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
    
    // MARK: Libraries
    var filterTableView: FilterTableView = FilterTableView<Library>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    var safeArea: UILayoutGuide!
    var libraries: [Library] = []
    
    private var libraryCard: CardView!
    
    
    func setUpTableView() {
        let card = CardView()
        libraryCard = card
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: kViewMargin).isActive = true
        card.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let studyLabel = UILabel()
        studyLabel.text = "Find your study spot"
        studyLabel.font = BMFont.bold(24)
        studyLabel.adjustsFontSizeToFitWidth = true
        studyLabel.textColor = BMColor.blackText
        card.addSubview(studyLabel)
        
        let bookImageView = UIImageView()
        bookImageView.contentMode = .scaleAspectFit
        bookImageView.image = bookIcon
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.clipsToBounds = true
        self.bookImageView = bookImageView
        
        card.addSubview(bookImageView)
        bookImageView.centerYAnchor.constraint(equalTo: studyLabel.centerYAnchor).isActive = true
        bookImageView.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        bookImageView.heightAnchor.constraint(equalToConstant: 26).isActive = true
        bookImageView.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        studyLabel.translatesAutoresizingMaskIntoConstraints = false
        studyLabel.leftAnchor.constraint(equalTo: bookImageView.rightAnchor, constant: 15).isActive = true
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
            Sort<Library>(label: "Nearby", sort: SortingFunctions.sortClose),
            Filter<Library>(label: "Open", filter: {lib in lib.isOpen ?? false}),
        ]
        filterTableView = FilterTableView<Library>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortAlph(item1:item2:), initialSelectedIndices: [0])
        self.filterTableView.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.kCellIdentifier)
        self.filterTableView.tableView.dataSource = self
        self.filterTableView.tableView.delegate = self

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dropPin(item: self.filterTableView.filteredData[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
