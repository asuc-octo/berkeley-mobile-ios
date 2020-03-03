//
//  ResourcesViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 128

class ResourcesViewController: UIViewController {
    private var scrollView: UIScrollView!
    
    private var resourcesLabel: UILabel!

    private var resourcesCard: CardView!
    private var resourcesTable: UITableView!
    
    private var resourceEntries: [ResourceEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground

        setupHeader()
        setupScrollView()
        setupResourcesList()
        
        DataManager.shared.fetch(source: ResourceDataSource.self) { resourceEntries in
            self.resourceEntries = resourceEntries as? [ResourceEntry] ?? []
            
            self.resourcesTable.reloadData()
        }
    }

}

extension ResourcesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = resourceEntries[indexPath.section].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resourceEntries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Color.cardBackground
        return headerView
    }
    
    
}

extension ResourcesViewController {
    // Header Label and Blobs
    func setupHeader() {
        resourcesLabel = UILabel()
        resourcesLabel.font = Font.bold(30)
        resourcesLabel.text = "What do you need?"
        view.addSubview(resourcesLabel)
        resourcesLabel.translatesAutoresizingMaskIntoConstraints = false
        resourcesLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        resourcesLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setConstraintsToView(top: view, bottom: view, left: view, right: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = resourcesCard.frame.maxY + view.layoutMargins.bottom
    }
    
    func setupResourcesList() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: view.topAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        scrollView.addSubview(table)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        table.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true

        resourcesCard = card
        resourcesTable = table
    }
    
}
