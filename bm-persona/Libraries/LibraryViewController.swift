//
//  LibraryViewController.swift
//  bm-persona
//
//  Created by Anna Gao on 11/6/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

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
        setupTableView()
    }
    
    func setupTableView() {
        //general setup and constraints
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let card = CardView()
        card.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
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
        filterTableView = FilterTableView<Library>(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortAlph(item1:item2:))
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
            let lib: Library = self.filterTableView.filteredData[indexPath.row]
            cell.updateContents(item: lib, imageUpdate: {
                DispatchQueue.global().async {
                    guard let imageURL = lib.imageURL, let imageData = try? Data(contentsOf: imageURL) else { return }
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        lib.image = image
                        if tableView.visibleCells.contains(cell) {
                            cell.cellImage.image = image
                        }
                    }
                }
            })
            return cell
        }
        return UITableViewCell()
    }
    
}

extension LibraryViewController {
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let state = handlePan(gesture: gesture)
        if state == .hidden {
            // get rid of the top detail drawer if user sends it to bottom of screen
            mainContainer?.dismissTop()
        }
    }
}
