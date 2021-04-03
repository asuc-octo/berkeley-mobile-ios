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
        // set all months that can be selected
        didSet {
            let sortedCalendarEntries = calendarEntries.sorted(by: { entry1, entry2 in
                return entry1.date < entry2.date
            })
            guard let firstDate = sortedCalendarEntries.first?.date,
                  let lastDate = sortedCalendarEntries.last?.date else {
                months = [(initialMonth, initialYear)]
                return
            }
            let firstComponents = Calendar.current.dateComponents([.month, .year], from: firstDate)
            let lastComponents = Calendar.current.dateComponents([.month, .year], from: lastDate)
            months = []
            // add every month from the earliest entry to the latest entry
            for year in firstComponents.year!...lastComponents.year! {
                let start = year == firstComponents.year ? firstComponents.month : 1
                let end = year == lastComponents.year ? lastComponents.month : 12
                for month in start!...end! {
                    months.append((month: month, year: year))
                }
            }
            // scroll to the initial month
            let row = months.firstIndex(where: { (month, year) in
                return month == initialMonth && year == initialYear
            }) ?? 0
            let indexPath = IndexPath(row: row, section: 0)
            monthSelector.reloadData()
            monthSelector.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
    }
    /// all months included in the selector
    var months: [(month: Int, year: Int)] = []
    private let monthSelector: UICollectionView = {
        let flow = UICollectionViewFlowLayout.init()
        flow.scrollDirection = .horizontal
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
    open var delegate: MonthSelectorDelegate?
    
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
    static let kCellSize: CGSize = CGSize(width: 32, height: 35)
    
    open var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.light(16)
        label.textAlignment = .center
        return label
    }()
    override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        return CGSize(
            width: size.width + layoutMargins.left + layoutMargins.right,
            height: MonthSelectCell.kCellSize.height
        )
    }
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                contentView.backgroundColor = Color.selectedButtonBackground
                label.textColor = .white
            } else {
                contentView.backgroundColor = Color.cardBackground
                label.textColor = Color.blackText
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
        contentView.layer.cornerRadius = bounds.height / 2
    }
    
    public func configure(month: Int) {
        label.text = DateFormatter().monthSymbols[month - 1]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonthSelectorView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthSelectCell.kCellIdentifier, for: indexPath)
        if let monthCell = cell as? MonthSelectCell {
            monthCell.configure(month: months[indexPath.row].month)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = MonthSelectCell()
        cell.configure(month: months[indexPath.row].month)
        return cell.intrinsicContentSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.monthSelected(month: months[indexPath.row].month, year: months[indexPath.row].year)
    }
}

protocol MonthSelectorDelegate {
    func monthSelected(month: Int, year: Int)
}
