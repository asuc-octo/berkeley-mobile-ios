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
    private weak var parentVC: UIViewController?
    private var calendarTable: UITableView = UITableView()
    private var calendarView: CalendarView = CalendarView()
    private var missingDataView: MissingDataView
    private var tableEntries: [EventCalendarEntry] = []
    private var calendarTableHeightConstraint: NSLayoutConstraint?
    
    var isLoading = false {
        didSet {
            reloadCalendarTableView()
        }
    }
    
    public init(parentVC: UIViewController) {
        self.parentVC = parentVC
        missingDataView = MissingDataView(parentView: calendarTable, text: "No events found")
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpScrollView()
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        scrollingStackView.stackView.addArrangedSubview(calendarView)
        
        calendarTable.backgroundColor = UIColor.clear
        calendarTable.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.kCellIdentifier)
        calendarTable.register(SkeletonLoadingCell.self, forCellReuseIdentifier: SkeletonLoadingCell.kCellIdentifier)
        calendarTable.rowHeight = EventTableViewCell.kCellHeight
        calendarTable.delegate = self
        calendarTable.dataSource = self
        calendarTable.showsVerticalScrollIndicator = false
        calendarTable.separatorStyle = .none
        calendarTable.translatesAutoresizingMaskIntoConstraints = false
        // prevent estimated heights so content size works
        calendarTable.estimatedRowHeight = 0
        calendarTable.estimatedSectionHeaderHeight = 0
        calendarTable.estimatedSectionFooterHeight = 0
        scrollingStackView.stackView.addArrangedSubview(calendarTable)
        calendarTableHeightConstraint = calendarTable.heightAnchor.constraint(equalToConstant: 300)
        calendarTableHeightConstraint?.isActive = true
    }
    
    public func setCalendarEntries(entries: [EventCalendarEntry]) {
        calendarView.calendarEntries = entries
        reloadCalendarTableView()
    }
    
    func setUpScrollView() {
        self.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    var scrollingStackView: ScrollingStackView = {
        let scrollingStackView = ScrollingStackView()
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        return scrollingStackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func reloadCalendarTableView() {
        if calendarView.calendarEntries.isEmpty {
            hideCalendarTable()
        } else {
            showCalendarTable()
            calendarTable.reloadData()
        }
    }
    
    private func showCalendarTable() {
        missingDataView.isHidden = true
        calendarTable.isHidden = false
    }
    
    private func hideCalendarTable() {
        missingDataView.isHidden = false
        missingDataView.isHidden = true
    }
}

// MARK: - Calendar Table Delegates

extension CalendarTablePairView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 5 : tableEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonLoadingCell.kCellIdentifier, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.kCellIdentifier, for: indexPath)
            
            if let cell = cell as? EventTableViewCell,
                let entry = tableEntries[safe: indexPath.row] {
                cell.cellConfigure(event: entry, type: entry.type, color: entry.color)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = tableEntries[safe: indexPath.row],
           let parentVC = parentVC {
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
        reloadCalendarTableView()
        if selectedEntries.isEmpty {
            calendarTableHeightConstraint?.constant = self.frame.height * 0.2
        } else {
            calendarTableHeightConstraint?.constant = min(calendarTable.contentSize.height, self.frame.height * 0.7)
        }
        self.layoutIfNeeded()
    }
}
