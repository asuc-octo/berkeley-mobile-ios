//
//  CalendarTablePairView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 3/6/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import SwiftUI
import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
fileprivate let kViewMargin: CGFloat = 6

/// Pairs a CalendarView with a UITableView that shows matching events
class CalendarTablePairView: UIView {
    private weak var parentVC: UIViewController?
    private var calendarTable = UITableView()
    private var calendarViewModel = BMCalendarViewModel()
    private var calendarView: UIView!
    private var missingDataView: MissingDataView
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
        configureCalendarView()
        
        scrollingStackView.stackView.addArrangedSubview(calendarView)
        
        calendarTable.backgroundColor = UIColor.clear
        calendarTable.register(SkeletonLoadingCell.self, forCellReuseIdentifier: SkeletonLoadingCell.kCellIdentifier)
        calendarTable.rowHeight = 86
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setCalendarEntries(entries: [EventCalendarEntry]) {
        calendarViewModel.setCalendarEntries(for: entries)
        reloadCalendarTableView()
    }
    
    private func setUpScrollView() {
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
    
    private func configureCalendarView() {
        let bmCalendarView = BMCalendarView() { [weak self] day in
            self?.scrollToDay(for: day)
        }
        
        calendarView = UIHostingController(rootView: bmCalendarView.environmentObject(calendarViewModel)).view
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.isUserInteractionEnabled = true
        calendarView.backgroundColor = .clear
    }
    
    private func reloadCalendarTableView() {
        if calendarViewModel.calendarEntries.isEmpty {
            hideCalendarTable()
        } else {
            showCalendarTable()
            calendarTable.reloadData()
            calendarTableScrollToToday()
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
    
    private func calendarTableScrollToToday() {
        let todayDay = Date().get(.day)
        scrollToDay(for: todayDay)
    }
    
    private func scrollToDay(for day: Int) {
        guard let tableEntryIndex = calendarViewModel.calendarEntries.firstIndex(where: { $0.date.get(.day) == day }) else {
            return
        }
        calendarTable.scrollToRow(at: IndexPath(row: tableEntryIndex, section: 0), at: .top, animated: true)
    }
}


// MARK: - Calendar Table Delegates

extension CalendarTablePairView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 5 : calendarViewModel.calendarEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonLoadingCell.kCellIdentifier, for: indexPath)
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "AcademicEventRowCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            if let entry = calendarViewModel.calendarEntries[safe: indexPath.row] {
                cell.contentConfiguration = UIHostingConfiguration {
                    AcademicEventRowView(event: entry, color: Color(entry.color), imageURL: entry.imageURL)
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = calendarViewModel.calendarEntries[safe: indexPath.row],
           let parentVC = parentVC {
            event.addToDeviceCalendar(vc: parentVC)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
