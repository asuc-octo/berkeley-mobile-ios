//
//  DiningMenuViewController.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/13/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

fileprivate let kViewMargin: CGFloat = 16

class DiningMenuViewController: UIViewController {

    private var menu: DiningMenu
    private var menuView: FilterTableView = FilterTableView<DiningItem>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))

    static let cellHeight: CGFloat = 45
    static let cellSpacingHeight: CGFloat = 5

    init(menu: DiningMenu, filter: FilterView? = nil, layoutMargins: UIEdgeInsets? = nil) {
        self.menu = menu
        super.init(nibName: nil, bundle: nil)

        view.clipsToBounds = true
        if let layoutMargins = layoutMargins {
            view.layoutMargins = layoutMargins
        }

        setUpMenu(filter: filter)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpMenu(filter: FilterView? = nil) {
        var filters: [Filter<DiningItem>] = [Filter<DiningItem>]()
        // Add filters for some common restrictions
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
        menuView = FilterTableView(frame: .zero, tableFunctions: filters, defaultSort: SortingFunctions.sortAlph(item1:item2:))
        self.menuView.tableView.register(DiningMenuCell.self, forCellReuseIdentifier: DiningMenuCell.kCellIdentifier)
        self.menuView.tableView.dataSource = self
        self.menuView.tableView.delegate = self

        menuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuView)
        self.menuView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        self.menuView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        self.menuView.topAnchor.constraint(equalTo: view.topAnchor, constant: kViewMargin).isActive = true
        self.menuView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true

        //TODO: sort func? currently same order as read in
        self.menuView.setData(data: menu)
        self.menuView.tableView.reloadData()
    }

    /* Create a filter named NAME which filters based on RESTRICTION.
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

extension DiningMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuView.filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: DiningMenuCell.kCellIdentifier, for: indexPath) as? DiningMenuCell,
            indexPath.row < self.menuView.filteredData.count {
            if let item: DiningItem = self.menuView.filteredData[safe: indexPath.row] {
                cell.nameLabel.text = item.name
                cell.item = item
                cell.setRestrictionIcons()
                cell.updateFaveButton()
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DiningMenuViewController.cellHeight + DiningMenuViewController.cellSpacingHeight
    }
}
