//
//  MonthSelectorView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 3/6/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class MonthSelectorView: UIView {
    var calendarEntries: [EventCalendarEntry] = [] {
        didSet {
            let sortedCalendarEntries = calendarEntries.sorted(by: { entry1, entry2 in
                return entry1.date < entry2.date
            })
            guard let firstDate = sortedCalendarEntries.first?.date,
                  let lastDate = sortedCalendarEntries.last?.date else {
                return
            }
            let firstComponents = Calendar.current.dateComponents([.month, .year], from: firstDate)
            let lastComponents = Calendar.current.dateComponents([.month, .year], from: lastDate)
            months = []
            for year in firstComponents.year!...lastComponents.year! {
                let start = year == firstComponents.year ? firstComponents.month : 1
                let end = year == lastComponents.year ? lastComponents.month : 12
                for month in start!...end! {
                    months.append((month: month, year: year))
                }
            }
            monthSelector.reloadData()
        }
    }
    var months: [(month: Int, year: Int)] = []
    private let monthSelector: UICollectionView = {
        let flow = UICollectionViewFlowLayout.init()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: 100, height: 30)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flow)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.register(MonthSelectCell.self, forCellWithReuseIdentifier: MonthSelectCell.kCellIdentifier)
        collection.backgroundColor = .clear
        return collection
    }()
    
    private var initialMonth: Int!
    private var initialYear: Int!
    
    public init(initialMonth: Int, initialYear: Int) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.initialMonth = initialMonth
        self.initialYear = initialYear
        monthSelector.delegate = self
        monthSelector.dataSource = self
        monthSelector.showsHorizontalScrollIndicator = false
        self.addSubview(monthSelector)
        monthSelector.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        monthSelector.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        monthSelector.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        monthSelector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.setHeightConstraint(35)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MonthSelectCell: UICollectionViewCell {
    static let kCellIdentifier = "monthSelectCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.light(16)
        return label
    }()
    private var month: Int!
    private var year: Int!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.contentView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 15).isActive = true
    }
    
    public func configure(month: Int, year: Int) {
        self.month = month
        self.year = year
        label.text = DateFormatter().monthSymbols[month - 1]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonthSelectorView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count > 0 ? months.count : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthSelectCell.kCellIdentifier, for: indexPath)
        if let monthCell = cell as? MonthSelectCell {
            if calendarEntries.count == 0 {
                monthCell.configure(month: initialMonth, year: initialYear)
            } else {
                monthCell.configure(month: months[indexPath.row].month, year: months[indexPath.row].year)
            }
        }
        return cell
    }
}
