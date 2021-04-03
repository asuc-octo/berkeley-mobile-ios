//
//  CampusResourceViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 10/31/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class CampusResourceViewController: UIViewController {
    private var resourcesCard: CardView!
    private var resourcesTable: FilterTableView = FilterTableView<Resource>(frame: .zero, tableFunctions: [], defaultSort: SortingFunctions.sortAlph(item1:item2:))
    
    private var resourceEntries: [Resource] = [] {
        didSet {
            resourcesTable.setData(data: self.resourceEntries)
            resourcesTable.update()
        }
    }

    /// If not empty, this view will present the filtered set of campus resources.
    private var resourceFilters: [Filter<Resource>] = []

    convenience init(type: ResourceType, notIn: Set<ResourceType>? = nil) {
        self.init(inSet: Set<ResourceType>([type]), notIn: notIn)
    }

    /// If `inSet` is non-nil, will filter resources for those matching those `ResourceType`s.
    /// If `notIn` is non-nil, will filter resources for those not in the given set of types.
    init(inSet: Set<ResourceType>? = nil, notIn: Set<ResourceType>? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let types = inSet {
            resourceFilters.append(Filter(label: "Type Filter: \(types)", filter: { resource in
                guard let resourceType = ResourceType(rawValue: resource.type ?? "") else { return false }
                return types.contains(resourceType)
            }))
        }
        if let types = notIn {
            resourceFilters.append(Filter(label: "Set Exclusion: \(types)", filter: { resource in
                guard let resourceType = ResourceType(rawValue: resource.type ?? "") else { return true }
                return !types.contains(resourceType)
            }))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupResourcesList()

        DataManager.shared.fetch(source: ResourceDataSource.self) { resourceEntries in
            let entries = resourceEntries as? [Resource] ?? []
            _ = Filter.apply(filters: self.resourceFilters, on: entries) { entries in
                DispatchQueue.main.async { self.resourceEntries = entries }
            }
        }
    }

}

extension CampusResourceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resourcesTable.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ResourceTableViewCell.kCellIdentifier, for: indexPath) as? ResourceTableViewCell {
            if let entry = resourcesTable.filteredData[safe: indexPath.row] {
                cell.cellConfigure(entry: entry)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CampusResourceDetailViewController(presentedModally: true)
        vc.resource = resourcesTable.filteredData[indexPath.row]
        present(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CampusResourceViewController {
    func setupResourcesList() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -kViewMargin).isActive = true

        let functions: [TableFunction] = [
            Sort<Resource>(label: "Nearby", sort: Resource.locationComparator()),
            Filter<Resource>(label: "Open", filter: {resource in resource.isOpen ?? false})
        ]
        resourcesTable = FilterTableView(frame: .zero, tableFunctions: functions, defaultSort: SortingFunctions.sortAlph(item1:item2:), initialSelectedIndices: [0])
        resourcesTable.tableView.register(ResourceTableViewCell.self, forCellReuseIdentifier: ResourceTableViewCell.kCellIdentifier)

        resourcesTable.tableView.delegate = self
        resourcesTable.tableView.dataSource = self

        resourcesTable.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(resourcesTable)

        resourcesTable.tableView.separatorStyle = .none
        resourcesTable.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        resourcesTable.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        resourcesTable.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        resourcesTable.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true

        resourcesCard = card
    }
}

