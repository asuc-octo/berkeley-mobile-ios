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

class OccupancyGraphCardView: CardView {
    var occupancyEntries: [DataEntry] = []
    var date: Date = Date()
    var graph: BarGraph = BarGraph()
    
    public init(occupancy: Occupancy, date: Date) {
        super.init(frame: CGRect.zero)
        self.date = date
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        updateValues(occupancy: occupancy, day: DayOfWeek.weekday(date))
        setUpViews(occupancy: occupancy)
    }
    
    public func updateValues(occupancy: Occupancy, day: DayOfWeek) {
        setOrderedEntries(occupancy: occupancy, day: day)
        graph.updateDataEntries(dataEntries: occupancyEntries)
    }
    
    private func setUpViews(occupancy: Occupancy) {
        let topLabelView = UIView()
        topLabelView.translatesAutoresizingMaskIntoConstraints = false
        topLabelView.addSubview(label)
        label.leftAnchor.constraint(equalTo: topLabelView.leftAnchor).isActive = true
        topLabelView.topAnchor.constraint(lessThanOrEqualTo: label.topAnchor).isActive = true
        topLabelView.bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor).isActive = true
        var rightConstraint = label.rightAnchor.constraint(equalTo: topLabelView.rightAnchor)
        if let status = occupancy.getOccupancyStatus(date: date) {
            let badge = status.badge()
            topLabelView.addSubview(badge)
            badge.rightAnchor.constraint(equalTo: topLabelView.rightAnchor).isActive = true
            topLabelView.topAnchor.constraint(lessThanOrEqualTo: badge.topAnchor).isActive = true
            topLabelView.bottomAnchor.constraint(greaterThanOrEqualTo: badge.bottomAnchor).isActive = true
            rightConstraint = label.rightAnchor.constraint(equalTo: badge.leftAnchor, constant: kViewMargin)
        }
        rightConstraint.isActive = true
        self.addSubview(topLabelView)
        topLabelView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        topLabelView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        
        self.addSubview(graph)
        topLabelView.topAnchor.constraint(equalTo: topLabelView.bottomAnchor, constant: kViewMargin).isActive = true
        topLabelView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        topLabelView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        topLabelView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
    }
    
    private func setOrderedEntries(occupancy: Occupancy, day: DayOfWeek) {
        occupancyEntries = []
        guard let occupancyForDay = occupancy.occupancy(for: day) else { return }
        for (index, hour) in occupancyForDay.keys.sorted().enumerated() {
            let percent = CGFloat(occupancyForDay[hour]!) / 100.0
            let bottomText = (index % 3 == 0) ? timeLabel(time: hour) : ""
            occupancyEntries.append(DataEntry(color: Color.barGraphEntry(alpha: percent), height: percent, bottomText: bottomText))
        }
    }
    
    private func timeLabel(time: Int) -> String {
        if time == 0 {
            return "12a"
        } else if time <= 11 {
            return String(time) + "a"
        } else if time <= 23 {
            return String(time) + "p"
        } else {
            return ""
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = Font.bold(18)
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
