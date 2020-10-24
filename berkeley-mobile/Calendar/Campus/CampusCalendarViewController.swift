//
//  CampusCalendarViewController.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 9/22/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

/// Displays the campus-wide and org. events in the Calendar tab.
class CampusCalendarViewController: UIViewController {
    /// Categories to include from all events
    private static let categories = ["Career"]

    private var scrollingStackView: ScrollingStackView!

    private var upcomingMissingView: MissingDataView!
    private var eventsCollection: CardCollectionView!

    private var calendarMissingView: MissingDataView!
    private var calendarTable: UITableView!

    private var calendarEntries: [EventCalendarEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Note: The top inset value will be also used as a vertical margin for `scrollingStackView`.
        self.view.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)

        setupScrollView()
        setupUpcoming()
        setupCalendarList()

        DataManager.shared.fetch(source: EventDataSource.self) { calendarEntries in
            self.calendarEntries = (calendarEntries as? [EventCalendarEntry])?.filter({ entry -> Bool in
                return CampusCalendarViewController.categories.contains(entry.category)
            }) ?? []

            self.calendarEntries = self.calendarEntries.sorted(by: {
                $0.date.compare($1.date) == .orderedAscending
            })
            
            // no current data, use old data for testing
            #if !DEBUG
            self.calendarEntries = self.calendarEntries.filter({
                $0.date > Date()
            })
            #endif
            if (self.calendarEntries.count == 0) {
                self.upcomingMissingView.isHidden = false
                self.calendarMissingView.isHidden = false
                self.calendarTable.isHidden = true
            } else {
                self.upcomingMissingView.isHidden = true
                self.calendarMissingView.isHidden = true
                self.calendarTable.isHidden = false
            }

            self.calendarTable.reloadData()
            self.eventsCollection.reloadData()
        }
    }
}

// MARK: - Calendar Table Delegates

extension CampusCalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CampusEventTableViewCell.kCellIdentifier, for: indexPath)
            as? CampusEventTableViewCell {
            if let entry = calendarEntries[safe: indexPath.row] {
                cell.updateContents(event: entry)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Upcoming Card Delegates

extension CampusCalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(calendarEntries.count, 4)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampusEventCollectionViewCell.kCellIdentifier, for: indexPath)
        if let card = cell as? CampusEventCollectionViewCell {
            if let entry = calendarEntries[safe: indexPath.row] {
                card.updateContents(event: entry)
            }
        }
        return cell
    }
}

// MARK: - View

extension CampusCalendarViewController {

    private func setupScrollView() {
        scrollingStackView = ScrollingStackView()
        scrollingStackView.setLayoutMargins(view.layoutMargins)
        scrollingStackView.scrollView.showsVerticalScrollIndicator = false
        scrollingStackView.stackView.spacing = kViewMargin
        view.addSubview(scrollingStackView)
        scrollingStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        scrollingStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollingStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollingStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: Upcoming Card

    private func setupUpcoming() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollingStackView.stackView.addArrangedSubview(card)

        let contentView = UIView()
        contentView.layer.masksToBounds = true
        card.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setConstraintsToView(top: card, bottom: card, left: card, right: card)

        let headerLabel = UILabel()
        headerLabel.font = Font.bold(24)
        headerLabel.text = "Upcoming"
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true

        let collectionView = CardCollectionView(frame: .zero)
        collectionView.register(CampusEventCollectionViewCell.self, forCellWithReuseIdentifier: CampusEventCollectionViewCell.kCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: card.layoutMargins.left, bottom: 0, right: card.layoutMargins.right)
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: CampusEventCollectionViewCell.kCardSize.height).isActive = true
        collectionView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true

        eventsCollection = collectionView
        upcomingMissingView = MissingDataView(parentView: collectionView, text: "No upcoming events")
    }

    // MARK: Calendar Table

    private func setupCalendarList() {
        let card = CardView()
        card.layoutMargins = kCardPadding
        scrollingStackView.stackView.addArrangedSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true

        let table = UITableView()
        table.register(CampusEventTableViewCell.self, forCellReuseIdentifier: CampusEventTableViewCell.kCellIdentifier)
        table.rowHeight = CampusEventTableViewCell.kCellHeight
        table.allowsSelection = false
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        card.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        table.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true

        calendarTable = table
        calendarMissingView = MissingDataView(parentView: card, text: "No events found")
    }
}
