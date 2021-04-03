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
    private var calendarDays: [CalendarDay] = []
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
            collection.reloadData()
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = Int(collection.frame.width) / collection.numberOfItems(inSection: 0)
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collection.collectionViewLayout = layout
        
        collection.reloadData()
        guard collection.contentSize.height > 0 && monthSelector.frame.height > 0 else { return }
        self.setHeightConstraint(collection.contentSize.height + monthSelector.frame.height)
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
        var calendarDays: [CalendarDay] = []
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
            calendarDays.append(CalendarDay(date: currDay, isCurrentMonth: currDay >= firstDay && currDay <= lastDay))
            currDay = calendar.date(byAdding: .day, value: 1, to: currDay)!
        }
        self.calendarDays = calendarDays
        self.collection.reloadData()
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
        label.font = Font.light(18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 15
        self.contentView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(text: String, isHeader: Bool, isGrayed: Bool, entries: [EventCalendarEntry] = [], day: Int? = nil) {
        label.text = text
        // get the set of all colors this day should be highlighted in based on the calendar events taking place
        var colors: Set<UIColor> = []
        for entry in entries {
            let entryDay = Calendar.current.component(.day, from: entry.date)
            if entryDay == day {
                colors.insert(entry.color)
            }
        }
        // if more than one color highlight, highlight in black
        if colors.count > 1 {
            contentView.backgroundColor = Color.Calendar.blackText
        } else if colors.count == 1 {
            contentView.backgroundColor = colors.first!
        } else {
            contentView.backgroundColor = .clear
        }
        if isHeader {
            label.textColor = Color.Calendar.dayOfWeekHeader
        } else if isGrayed {
            label.textColor = Color.Calendar.grayedText
        } else {
            if colors.isEmpty {
                label.textColor = Color.Calendar.blackText
            } else {
                label.textColor = .white
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
                calendarCell.configure(text: text, isHeader: true, isGrayed: false)
            } else {
                let cellIndex = (indexPath.section - 1) * collectionView.numberOfItems(inSection: indexPath.section) + indexPath.row
                let calendarDay = calendarDays[cellIndex]
                let day = calendar.dateComponents([.day], from: calendarDay.date).day!
                // only highlight cells for days in the current month
                if calendarDay.isCurrentMonth {
                    calendarCell.configure(text: String(day), isHeader: false, isGrayed: !calendarDay.isCurrentMonth, entries: currentMonthCalendarEntries, day: day)
                } else {
                    calendarCell.configure(text: String(day), isHeader: false, isGrayed: !calendarDay.isCurrentMonth)
                }
            }
        }
        return cell
    }
}

extension CalendarView: MonthSelectorDelegate {
    func monthSelected(month: Int, year: Int) {
        self.setMonth(month: month, year: year)
    }
}

/// represents a day in a calendar
struct CalendarDay {
    var date: Date
    /// whether this day is a part of the current month
    var isCurrentMonth: Bool
}

protocol CalendarViewDelegate {
    func didChangeMonth(selectedEntries: [EventCalendarEntry]) -> Void
}
