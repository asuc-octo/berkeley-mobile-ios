//
//  CalendarView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 11/21/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class CalendarView: UIView {
    private var year: Int!
    private var month: Int!
    private var calendar = Calendar.current
    private var calendarDays: [CalendarDay] = []
    
    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.kCellIdentifier)
        collection.backgroundColor = .clear
        return collection
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.goTo(month: calendar.component(.month, from: Date()), year: calendar.component(.year, from: Date()))
        collection.delegate = self
        collection.dataSource = self
        self.addSubview(collection)
        collection.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        collection.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
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
    }
    
    public func goTo(month: Int, year: Int) {
        if year == self.year && month == self.month {
            return
        }
        self.year = year
        self.month = month
        setCalendarCells()
    }
    
    private func setCalendarCells() {
        var calendarDays: [CalendarDay] = []
        let firstDay = calendar.date(from: DateComponents(year: self.year, month: self.month, day: 1))!
        
        // add gray last month days to the calendar
        let numberPreviousDays = firstDay.weekday()
        var day = Date.daysInMonth(date: calendar.date(byAdding: .month, value: -1, to: firstDay)!)
        for _ in 0..<numberPreviousDays {
            calendarDays.append(CalendarDay(year: year, month: month, day: day, isCurrentMonth: false))
            day -= 1
        }
        
        // add current month days
        let daysThisMonth = Date.daysInMonth(date: firstDay)
        for day in 1...daysThisMonth {
            calendarDays.append(CalendarDay(year: year, month: month, day: day, isCurrentMonth: true))
        }
        
        // add gray next month days to the end
        day = 1
        while calendarDays.count % 7 != 0 {
            calendarDays.append(CalendarDay(year: year, month: month, day: day, isCurrentMonth: false))
            day += 1
        }
        
        self.calendarDays = calendarDays
        self.collection.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
        
        self.contentView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(text: String, isHeader: Bool, isGrayed: Bool) {
        label.text = text
        
        if isHeader {
            label.textColor = Color.Calendar.dayOfWeekHeader
        } else if isGrayed {
            label.textColor = Color.Calendar.grayedText
        } else {
            label.textColor = Color.Calendar.blackText
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
            if indexPath.section == 0, let text = DayOfWeek(rawValue: indexPath.row)?.charRepresentation() {
                calendarCell.configure(text: text, isHeader: true, isGrayed: false)
            } else {
                let cellIndex = (indexPath.section - 1) * collectionView.numberOfItems(inSection: indexPath.section) + indexPath.row
                let calendarDay = calendarDays[cellIndex]
                calendarCell.configure(text: String(calendarDay.day), isHeader: false, isGrayed: !calendarDay.isCurrentMonth)
            }
        }
        return cell
    }
}

struct CalendarDay {
    var year: Int
    var month: Int
    var day: Int
    var isCurrentMonth: Bool
}

extension Date {
    static func daysInMonth(date: Date) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
}
