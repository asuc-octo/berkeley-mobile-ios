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
            
            // TODO: - Remove temporary event
            self.calendarEntries.append(CalendarEntry(name: "Associated Students of California - OCTO Retreat", campusLocation: "Eshleman Hall", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, eventType: "College of Engineering"))
            
            self.calendarEntries.append(CalendarEntry(name: "Phase II Deadline for Transfer Students", campusLocation: "Eshleman Hall", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, eventType: "General"))
            
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EventTableViewCell()
        cell.cellConfigure(entry: calendarEntries[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(calendarEntries[indexPath.section].name)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return calendarEntries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
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

        calendarCard = card
        calendarTable = table
    }
}
