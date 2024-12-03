//
//  CalendarView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 11/21/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

/// A Custom calendar that can highlight cells based on a list of EventCalendarEntries
class CalendarView: UIView {
    /// currently selected month and year
    private var year: Int!
    private var month: Int!
    private var calendar = Calendar.current
    /// days currently displayed on the calendar
    private var calendarDays: [(day: Int, isCurrentMonth: Bool)] = []
    /// delegate for when the month changes
    open var delegate: CalendarViewDelegate? {
        didSet {
            delegate?.didChangeMonth(selectedEntries: currentMonthCalendarEntries)
        }
    }
    /// all calendar entries relevant to this calendar
    var calendarEntries: [EventCalendarEntry] = [] {
        didSet {
            monthSelector.calendarEntries = calendarEntries
            setCurrentMonthEntries()
        }
    }
    /// the calendar entries for the currently selected month
    var currentMonthCalendarEntries: [EventCalendarEntry] = [] {
        didSet {
            reloadCells()
            delegate?.didChangeMonth(selectedEntries: currentMonthCalendarEntries)
        }
    }
    
    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.kCellIdentifier)
        collection.backgroundColor = .clear
        return collection
    }()
    
    private var monthSelector: MonthSelectorView!
    /// the height constraint to resize the collection view based on the height of the contents
    private var collectionHeightConstraint: NSLayoutConstraint?

    public init() {
        super.init(frame: .zero)
        let initialMonth = calendar.component(.month, from: Date())
        let initialYear = calendar.component(.year, from: Date())
        monthSelector = MonthSelectorView(initialMonth: initialMonth, initialYear: initialYear)
        monthSelector.delegate = self
        self.setMonth(month: initialMonth, year: initialYear)
        
        self.addSubview(monthSelector)
        monthSelector.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        monthSelector.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        monthSelector.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        self.addSubview(collection)
        collection.topAnchor.constraint(equalTo: self.monthSelector.bottomAnchor, constant: 6).isActive = true
        collection.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        // set temporary value for height constraint, will be adjusted whenever collection reloads
        collectionHeightConstraint = collection.heightAnchor.constraint(equalToConstant: 300)
        collectionHeightConstraint?.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = Int(collection.frame.width) / collection.numberOfItems(inSection: 0)
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collection.collectionViewLayout = layout
        
        reloadCells()
    }
    
    /// set the calendar's month
    private func setMonth(month: Int, year: Int) {
        if year == self.year && month == self.month {
            return
        }
        self.year = year
        self.month = month
        setCalendarCells()
        setCurrentMonthEntries()
    }
    
    /// update the calendar entries for the current month
    private func setCurrentMonthEntries() {
        var entries: [EventCalendarEntry] = []
        for entry in calendarEntries {
            let components = Calendar.current.dateComponents([.month, .year], from: entry.date)
            if let entryMonth = components.month, let entryYear = components.year,
               month == entryMonth, year == entryYear {
                entries.append(entry)
            }
        }
        currentMonthCalendarEntries = entries
    }
    
    /// update the cells displaying days in the current month
    private func setCalendarCells() {
        calendarDays = []
        guard let firstDay = calendar.date(from: DateComponents(year: self.year, month: self.month, day: 1)),
              let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDay) else {
            return
        }
        var currDay = firstDay
        // go backwards from the first day of the month to the closest Sunday
        while currDay.weekday() != 0 {
            currDay = calendar.date(byAdding: .day, value: -1, to: currDay)!
        }
        // add all calendar days from the first Sunday before the month to the last Sunday after the month
        while currDay <= lastDay || currDay.weekday() != 0 {
            let dayComponent = calendar.component(.day, from: currDay)
            calendarDays.append((day: dayComponent, isCurrentMonth: currDay >= firstDay && currDay <= lastDay))
            currDay = calendar.date(byAdding: .day, value: 1, to: currDay)!
        }
        reloadCells()
    }
    
    private func reloadCells() {
        collection.reloadData()
        // resize the collection view whenever the cells are reloaded
        collectionHeightConstraint?.constant = collection.collectionViewLayout.collectionViewContentSize.height
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// cells for days in a calendar
class CalendarCell: UICollectionViewCell {
    static let kCellIdentifier = "calendarCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = BMFont.light(18)
        return label
    }()
    let highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(highlightView)
        highlightView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        highlightView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        highlightView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        highlightView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.8).isActive = true
        highlightView.layer.cornerRadius = 10
        
        highlightView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: highlightView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: highlightView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // configure this cell to show a day of the week as part of the calendar header
    fileprivate func configureHeader(text: String) {
        label.text = text
        label.textColor = BMColor.Calendar.dayOfWeekHeader
        label.font = BMFont.light(18)
        highlightView.backgroundColor = .clear
    }
    
    // configure this cell to show a day of the month and highlight it appropriately
    fileprivate func configureDay(entries: [EventCalendarEntry] = [],
                             calendarDay: (day: Int, isCurrentMonth: Bool),
                             boldText: Bool = false) {
        label.text = String(calendarDay.day)
        // only highlight days from the current month
        if !calendarDay.isCurrentMonth {
            label.textColor = BMColor.Calendar.grayedText
            highlightView.backgroundColor = .clear
        } else {
            // get all colors this day should be highlighted in based on the calendar events taking place
            var colors: Set<UIColor> = []
            for entry in entries {
                let entryDay = entry.date.get(.day)
                if entryDay == calendarDay.day {
                    colors.insert(entry.color)
                }
            }
            // if more than one color highlight, highlight in black
            if colors.count > 1 {
                highlightView.backgroundColor = BMColor.Calendar.blackText
            } else if colors.count == 1 {
                highlightView.backgroundColor = colors.first!
            } else {
                highlightView.backgroundColor = .clear
            }
            if colors.isEmpty {
                label.textColor = BMColor.Calendar.blackText
            } else {
                label.textColor = .white
            }
        }
        if boldText {
            label.font = BMFont.bold(20)
        } else {
            label.font = BMFont.light(18)
        }
    }
    
    func performTapAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
            }
        }
    }
}

extension CalendarView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calendarDays.count / 7 + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.kCellIdentifier, for: indexPath)
        if let calendarCell = cell as? CalendarCell {
            // if in the first row, this is a day of week header
            if indexPath.section == 0, let text = DayOfWeek(rawValue: indexPath.row)?.charRepresentation() {
                calendarCell.configureHeader(text: text)
            } else {
                let cellIndex = getCellIndex(with: indexPath, in: collectionView)
                let calendarDay = calendarDays[cellIndex]
                // highlight and bold the text if the cell is for today
                let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                let boldText = year == todayComponents.year && month == todayComponents.month && calendarDay.day == todayComponents.day && calendarDay.isCurrentMonth
                calendarCell.configureDay(entries: currentMonthCalendarEntries, calendarDay: calendarDay, boldText: boldText)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellIndex = getCellIndex(with: indexPath, in: collectionView)
        
        guard cellIndex >= 0 else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell
        let calendarDay = calendarDays[cellIndex]
        let isTappable = currentMonthCalendarEntries.contains(where: { $0.date.get(.day) == calendarDay.day })
        
        if isTappable {
            delegate?.didSelectDay(day: calendarDay.day)
            cell?.performTapAnimation()
        }
    }
    
    private func getCellIndex(with indexPath: IndexPath, in collectionView: UICollectionView) -> Int {
        return (indexPath.section - 1) * collectionView.numberOfItems(inSection: indexPath.section) + indexPath.row
    }
}

extension CalendarView: MonthSelectorDelegate {
    /// if a month is selected using the MonthSelector, change this calendar's month
    func monthSelected(month: Int, year: Int) {
        self.setMonth(month: month, year: year)
    }
}

protocol CalendarViewDelegate {
    /// delegate is alerted when the month changes and is given the EventCalendarEntries shown for the current month
    func didChangeMonth(selectedEntries: [EventCalendarEntry]) -> Void
    /// delegate is alerted when a valid day is tapped
    func didSelectDay(day: Int) -> Void
}
