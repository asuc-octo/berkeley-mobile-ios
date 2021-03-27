//
//  CalendarTablePairView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 3/6/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
fileprivate let kViewMargin: CGFloat = 6

class CalendarTablePairView: UIView {
    private var parentVC: UIViewController

    private var calendarTable: UITableView!
    private var calendarView: CalendarView = CalendarView()
    private var missingDataView: MissingDataView!
    
    var calendarEntries: [EventCalendarEntry] = [] {
        didSet {
            calendarView.calendarEntries = calendarEntries
            setCurrentMonthEntries()
        }
    }
    private var currentMonthCalendarEntries: [EventCalendarEntry] = []
    
    public init(parentVC: UIViewController) {
        self.parentVC = parentVC
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let tableView = UITableView()
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.kCellIdentifier)
        tableView.rowHeight = EventTableViewCell.kCellHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        calendarTable = tableView
        missingDataView = MissingDataView(parentView: self, text: "No events found")
        
        self.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        calendarView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        calendarView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        calendarView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -kViewMargin).isActive = true
        calendarView.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive = true
        calendarView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Calendar Table Delegates

extension CalendarTablePairView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMonthCalendarEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.kCellIdentifier, for: indexPath)
            as? EventTableViewCell {
            if let entry = currentMonthCalendarEntries[safe: indexPath.row] {
                cell.cellConfigure(event: entry, type: entry.type, color: entry.color)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = currentMonthCalendarEntries[safe: indexPath.row] {
            event.addToDeviceCalendar(vc: parentVC)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CalendarTablePairView: CalendarViewDelegate {
    func didChangeMonth() {
        setCurrentMonthEntries()
    }
    
    private func setCurrentMonthEntries() {
        currentMonthCalendarEntries = []
        for entry in calendarEntries {
            let components = Calendar.current.dateComponents([.month, .year], from: entry.date)
            if let entryMonth = components.month, let entryYear = components.year,
               calendarView.getMonth() == entryMonth, calendarView.getYear() == entryYear {
                currentMonthCalendarEntries.append(entry)
            }
        }
        calendarTable.reloadData()
        calendarView.currentCalendarEntries = currentMonthCalendarEntries
    }
}
