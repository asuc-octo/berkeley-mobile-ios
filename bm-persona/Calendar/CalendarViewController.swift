//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 128


class CalendarViewController: UIViewController {
    private var scrollView: UIScrollView!
    
    private var eventsLabel: UILabel!
    
    private var calendarTable: UITableView!
    private var calendarCard: CardView!
    
    private var calendarEntries: [CalendarEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        self.view.backgroundColor = Color.modalBackground
        
        setupHeader()
        setupScrollView()
        setupCalendarList()
        
        DataManager.shared.fetch(source: CalendarDataSource.self) { calendarEntries in
            self.calendarEntries = calendarEntries as? [CalendarEntry] ?? []
            self.calendarTable.reloadData()
        }
    }

}

// MARK: - UITableViewDelegate

// Dummy Data
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let nameLabel = UILabel()
        cell.addSubview(nameLabel)
        nameLabel.text = calendarEntries[indexPath.row].name
        nameLabel.sizeToFit()
        return cell
    }
    
}

extension CalendarViewController {
    // Events Label and Blobs
    func setupHeader() {
        eventsLabel = UILabel()
        eventsLabel.font = Font.bold(24)
        eventsLabel.text = "Events"
        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        eventsLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    }
    
    // ScrollView
    func setupScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setConstraintsToView(top: view, bottom: view, left: view, right: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = calendarCard.frame.maxY + view.layoutMargins.bottom
    }
    
    // Calendar Table
    func setupCalendarList() {
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
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        table.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true

        calendarCard = card
        calendarTable = table
    }
}
