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

/// Pairs a CalendarView with a UITableView that shows matching events
class CalendarTablePairView: UIView {
    private var parentVC: UIViewController
    private var calendarTable: UITableView = UITableView()
    private var calendarView: CalendarView = CalendarView()
    private var missingDataView: MissingDataView
    private var tableEntries: [EventCalendarEntry] = []
    
    public init(parentVC: UIViewController) {
        self.parentVC = parentVC
        missingDataView = MissingDataView(parentView: calendarTable, text: "No events found")
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        calendarTable.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.kCellIdentifier)
        calendarTable.rowHeight = EventTableViewCell.kCellHeight
        calendarTable.delegate = self
        calendarTable.dataSource = self
        calendarTable.showsVerticalScrollIndicator = false
        calendarTable.separatorStyle = .none
        self.addSubview(calendarTable)
        calendarTable.translatesAutoresizingMaskIntoConstraints = false
        calendarTable.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        calendarTable.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        calendarTable.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        calendarView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        calendarView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        calendarView.bottomAnchor.constraint(equalTo: calendarTable.topAnchor, constant: -kViewMargin).isActive = true
        calendarView.delegate = self
    }
    
    public func setCalendarEntries(entries: [EventCalendarEntry]) {
        calendarView.calendarEntries = entries
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Calendar Table Delegates

extension CalendarTablePairView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.kCellIdentifier, for: indexPath)
            as? EventTableViewCell {
            if let entry = tableEntries[safe: indexPath.row] {
                cell.cellConfigure(event: entry, type: entry.type, color: entry.color)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = tableEntries[safe: indexPath.row] {
            event.addToDeviceCalendar(vc: parentVC)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CalendarTablePairView: CalendarViewDelegate {
    // when the calendar changes month, update the table
    func didChangeMonth(selectedEntries: [EventCalendarEntry]) {
        if selectedEntries.isEmpty {
            missingDataView.isHidden = false
        } else {
            missingDataView.isHidden = true
        }
        tableEntries = selectedEntries
        calendarTable.reloadData()
    }
}
