//
//  OpenTimesCardView.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

// Displays the open times for the current day when collapsed and for all days when opened.
class OpenTimesCardView: CollapsibleCardView {
    var item: HasOpenTimes!

    public init(item: HasOpenTimes, openedAction: (() -> Void)? = nil) {
        super.init()
        self.item = item
        super.setContents(collapsedView: collapsedView(), openedView: openedView(), openedAction: openedAction, leftIcon: clockIcon)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func collapsedView() -> UIView {
        let defaultView = UIView()
        defaultView.translatesAutoresizingMaskIntoConstraints = false
        guard let weeklyHours = item.weeklyHours, weeklyHours.hoursForWeekday(DayOfWeek.weekday(Date())).count > 0 else {
            return defaultView
        }
        var leftView: UIView?
        var rightView: UIView?
        
        if let isOpen = item.isOpen {
            if isOpen {
                openTag.text = "Open"
                openTag.backgroundColor = Color.openTag
            } else {
                openTag.text = "Closed"
                openTag.backgroundColor = Color.closedTag
            }
            openTag.widthAnchor.constraint(equalToConstant: 50).isActive = true
            leftView = openTag
        }
        
        // collapsed view shows the next open interval for the current day or a "closed" label
        if let nextOpenInterval = item.nextOpenInterval() {
            rightView = timeSpanLabel(interval: nextOpenInterval, shouldBoldIfCurrent: false)
        } else {
            rightView = closedLabel()
        }
        
        return leftRightView(leftView: leftView, rightView: rightView, centered: true) ?? defaultView
    }
    
    func openedView() -> UIStackView {
        guard item.weeklyHours != nil else { return UIStackView() }
        // stack of all the days displayed when opened
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 5
        for day in DayOfWeek.allCases {
            let dayLabel = UILabel()
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            // if this is the current day, bold the day name label
            if DayOfWeek.weekday(Date()) == day {
                dayLabel.font = Font.bold(10)
            } else {
                dayLabel.font = Font.light(10)
            }
            dayLabel.text = day.stringRepresentation()
            if let dayView = leftRightView(leftView: dayLabel, rightView: hourSpanLabelStack(weekday: day)) {
                view.addArrangedSubview(dayView)
            }
        }
        return view
    }
    
    // stacks all the hour intervals for one day into a vertical stack
    func hourSpanLabelStack(weekday: DayOfWeek) -> UIStackView? {
        guard let weeklyHours = item.weeklyHours else { return nil }
        let intervals = weeklyHours.hoursForWeekday(weekday)
        // if no data is available for the day, shows as empty
        guard intervals.count > 0 else { return nil }
        
        // stack for all the intervals in one day
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .trailing
        view.distribution = .equalSpacing
        view.spacing = 5
        
        for interval in intervals {
            // prevents adding 0 second intervals (that mean closed all day)
            if interval.duration > 0 {
                view.addArrangedSubview(timeSpanLabel(interval: interval))
            }
        }
        // if there are intervals, but none of them are > 0 seconds, closed all day
        if view.arrangedSubviews.count == 0 {
            view.addArrangedSubview(closedLabel(bold: DayOfWeek.weekday(Date()) == weekday))
        }
        return view
    }
    
    // label formatting the interval into a label
    // shouldBoldIfCurrent: whether the interval should be bold if the current time falls within its bounds (set to false for the collapsedView)
    func timeSpanLabel(interval: DateInterval, shouldBoldIfCurrent: Bool = true) -> UILabel {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = formatter.string(from: interval.start, to: interval.end)
        // bold label if the current time is in the interval and it's in the openedView
        if shouldBoldIfCurrent, interval.contains(Date()) {
            label.font = Font.bold(10)
        } else {
            label.font = Font.light(10)
        }
        return label
    }
    
    // label to display that the item is closed
    // bold set to true if the item is closed all day for the current day
    private func closedLabel(bold: Bool = false) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Closed"
        if bold {
            label.font = Font.bold(10)
        } else {
            label.font = Font.light(10)
        }
        return label
    }
    
    // a left aligned and right aligned view that are paired together
    // centered: whether the views are vertically centered (top aligned otherwise). set to true for the collapsedView and false for the elements in the openedView
    private func leftRightView(leftView: UIView?, rightView: UIView?, centered: Bool = false) -> UIView? {
        guard leftView != nil || rightView != nil else { return nil }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // left bound to constrain the right view to is either the far left (if no left view), or the left view
        var leftBound = view
        if let leftView = leftView {
            view.addSubview(leftView)
            leftView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            view.topAnchor.constraint(lessThanOrEqualTo: leftView.bottomAnchor).isActive = true
            view.bottomAnchor.constraint(greaterThanOrEqualTo: leftView.bottomAnchor).isActive = true
            if centered {
                leftView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            } else {
                leftView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
            leftBound = leftView
        }
        
        if let rightView = rightView {
            view.addSubview(rightView)
            rightView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            rightView.leftAnchor.constraint(greaterThanOrEqualTo: leftBound.rightAnchor, constant: kViewMargin).isActive = true
            view.topAnchor.constraint(lessThanOrEqualTo: rightView.bottomAnchor).isActive = true
            view.bottomAnchor.constraint(greaterThanOrEqualTo: rightView.bottomAnchor).isActive = true
            if centered {
                rightView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            } else {
                rightView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
        }
        
        return view
    }
    
    let clockIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Clock")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let openTag: TagView = {
        let tag = TagView(origin: .zero, text: "", color: .clear)
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
}