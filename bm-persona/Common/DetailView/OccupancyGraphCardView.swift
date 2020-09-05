//
//  OccupancyGraphCardView.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

/// A card with a bar graph showing occupancy by hour
class OccupancyGraphCardView: CardView {
    var occupancyEntries: [DataEntry] = []
    var graph = BarGraph()
    var isOpen: Bool?
    
    public init(occupancy: Occupancy, isOpen: Bool?) {
        super.init(frame: CGRect.zero)
        self.isOpen = isOpen
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        setOrderedEntries(occupancy: occupancy, day: DayOfWeek.weekday(Date()))
        setUpViews(occupancy: occupancy)
    }
    
    private func setUpViews(occupancy: Occupancy) {
        let topLabelView = UIView()
        topLabelView.translatesAutoresizingMaskIntoConstraints = false
        topLabelView.setContentHuggingPriority(.required, for: .vertical)
        topLabelView.addSubview(occupancyLabel)
        occupancyLabel.leftAnchor.constraint(equalTo: topLabelView.leftAnchor).isActive = true
        topLabelView.topAnchor.constraint(lessThanOrEqualTo: occupancyLabel.topAnchor).isActive = true
        topLabelView.bottomAnchor.constraint(greaterThanOrEqualTo: occupancyLabel.bottomAnchor).isActive = true
        var rightConstraint = occupancyLabel.rightAnchor.constraint(equalTo: topLabelView.rightAnchor)
        if isOpen ?? true, let status = occupancy.getCurrentOccupancyStatus() {
            let badge = status.badge()
            topLabelView.addSubview(badge)
            badge.rightAnchor.constraint(equalTo: topLabelView.rightAnchor).isActive = true
            topLabelView.topAnchor.constraint(lessThanOrEqualTo: badge.topAnchor).isActive = true
            topLabelView.bottomAnchor.constraint(greaterThanOrEqualTo: badge.bottomAnchor).isActive = true
            rightConstraint = occupancyLabel.rightAnchor.constraint(equalTo: badge.leftAnchor, constant: -1 * kViewMargin)
        }
        rightConstraint.isActive = true
        self.addSubview(topLabelView)
        topLabelView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        topLabelView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        topLabelView.bottomAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        topLabelView.rightAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        
        self.addSubview(graph)
        graph.topAnchor.constraint(equalTo: topLabelView.bottomAnchor, constant: kViewMargin).isActive = true
        graph.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        graph.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        graph.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        graph.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    /**
     Sets the entries for the graph by sorting occupancy hours chronologically and determining the color, height, and text for each bar.
     - parameter occupancy: occupancy object used to set the entries
     - parameter day: the day of the week displayed in the graph
     */
    private func setOrderedEntries(occupancy: Occupancy, day: DayOfWeek) {
        occupancyEntries = []
        guard let occupancyForDay = occupancy.occupancy(for: day) else { return }
        let sortedHours = occupancyForDay.keys.sorted()
        guard let minHour = sortedHours.first, let maxHour = sortedHours.last else { return }
        let currentHour = Calendar.current.component(.hour, from: Date())
        let liveDataAvailable = occupancy.liveOccupancy != nil
        // the position of the bar in the graph
        var index = 0
        for hour in min(minHour, currentHour)...max(maxHour, currentHour) {
            // hour is shown for hours that are a multiple of 3
            let bottomText = (hour % 3 == 0) ? timeText(time: hour) : ""
            // add blue live data bar if necessary
            var liveData: DataEntry?
            if hour == currentHour, isOpen ?? true, let live = occupancy.liveOccupancy {
                liveData = DataEntry(color: Color.barGraphEntryCurrent, height: CGFloat(live) / 100.0, bottomText: bottomText, index: index)
            }
            if let occupancyForHour = occupancyForDay[hour] {
                let percent = CGFloat(occupancyForHour) / 100.0
                // alpha for bar color linearly scales from 0.2 to 1.0 based on percentage occupancy
                let alpha = 0.2 + percent * 0.8
                var color: UIColor
                if hour == currentHour && isOpen ?? true {
                    if liveDataAvailable {
                        // both live and historic bars solid
                        color = Color.barGraphEntry(alpha: 1)
                    } else {
                        // historic bar is blue
                        color = Color.barGraphEntryCurrent
                    }
                } else {
                    color = Color.barGraphEntry(alpha: alpha)
                }
                // append entries in proper order if live data and historic data available
                // taller bar added first because the taller bar must be behind
                let nextEntry = DataEntry(color: color, height: percent, bottomText: bottomText, index: index)
                if let liveEntry = liveData {
                    let nextEntries: [DataEntry] = liveEntry.height > nextEntry.height ? [liveEntry, nextEntry] : [nextEntry, liveEntry]
                    occupancyEntries.append(contentsOf: nextEntries)
                    index += nextEntries.count
                } else {
                    occupancyEntries.append(nextEntry)
                    index += 1
                }
            } else {
                occupancyEntries.append(DataEntry(color: UIColor.clear, height: 0, bottomText: bottomText, index: index))
                index += 1
            }
        }
        graph.dataEntries = occupancyEntries
    }
    
    /**
     - parameter time: the hour of the day (24 hr time)
     - returns: text for this hour that should be displayed below the bar
     */
    private func timeText(time: Int) -> String {
        if time == 0 {
            return "12a"
        } else if time <= 11 {
            return String(time) + "a"
        } else if time == 12 {
            return "12p"
        } else if time <= 23 {
            return String(time - 12) + "p"
        } else {
            return ""
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let occupancyLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(16)
        label.textColor = Color.blackText
        label.text = "Occupancy"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
