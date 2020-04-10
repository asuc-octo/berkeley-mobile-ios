//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

class CalendarViewController: UIViewController {
    private var scrollView: UIScrollView!
    private var eventsLabel: UILabel!
    
    private var upcomingCard: CardView!
    private var eventsCollection: CardCollectionView!
    
    private var calendarTable: UITableView!
    private var calendarCard: CardView!
    private var calendarEntries: [CalendarEntry] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        self.view.backgroundColor = Color.modalBackground
        
        setupHeader()
        setupScrollView()
        setupUpcoming()
        setupCalendarList()
        
        DataManager.shared.fetch(source: CalendarDataSource.self) { calendarEntries in
            self.calendarEntries = calendarEntries as? [CalendarEntry] ?? []
            
            // TODO: - Remove temporary events
            self.calendarEntries = self.calendarEntries.sorted(by: {
                $0.date!.compare($1.date!) == .orderedAscending
            })
        
            self.calendarEntries = self.calendarEntries.filter({
                $0.date! > Date()
            })
            self.calendarTable.reloadData()
        }
    }

}

// MARK: - UITableViewDelegate

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EventTableViewCell()
        cell.cellConfigure(entry: calendarEntries[indexPath.row])
        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EventTableViewCell.kCellHeight
    }

}

// MARK: - UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(calendarEntries.count, 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionView.kCellIdentifier, for: indexPath)
        if let card = cell as? CardCollectionViewCell {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var dateString = dateFormatter.string(from: calendarEntries[indexPath.row].date!)
            if calendarEntries[indexPath.row].date == Date() {
                dateString = "Today / " + dateString
            }
            card.title.text = calendarEntries[indexPath.row].name
            card.subtitle.text = dateString
            card.badge.text = "Academic"
            card.badge.backgroundColor = EventTableViewCell.getEntryColor(entryType: calendarEntries[indexPath.row].eventType ?? "")
        }
        return cell
    }
    
}


extension CalendarViewController {
    // Events Label and Blobs
    func setupHeader() {
        eventsLabel = UILabel()
        eventsLabel.font = Font.bold(30)
        eventsLabel.text = "Events"
        view.addSubview(eventsLabel)
        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
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
        card.topAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: 16).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.allowsSelection = false
        scrollView.addSubview(table)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        table.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true

        calendarCard = card
        calendarTable = table
    }
    
    func setupUpcoming() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: eventsLabel.bottomAnchor, constant: 16).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let contentView = UIView()
        contentView.layer.masksToBounds = true
        card.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setConstraintsToView(top: card, bottom: card, left: card, right: card)
        
        let headerLabel = UILabel()
        headerLabel.font = Font.bold(24)
        headerLabel.text = "Upcoming"
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let collectionView = CardCollectionView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: card.layoutMargins.left, bottom: 0, right: card.layoutMargins.right)
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: CardCollectionViewCell.kCardSize.height).isActive = true
        collectionView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        
        upcomingCard = card
        eventsCollection = collectionView
    }
}
