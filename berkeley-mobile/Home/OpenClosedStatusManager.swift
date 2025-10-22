//
//  OpenClosedStatusManager.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/18/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import os
import UIKit

protocol OpenClosedStatusManagerDelegate: AnyObject {
    func didTimerFire(for itemID: String, with timer: Timer)
}

/// `OpenClosedStatusManager` manages associated `Timer` objects and callbacks to items that conform to `HasOpenClosedStatus` for observation.
class OpenClosedStatusManager {
    private struct Constants {
        static let timerUserInfoKey = "itemID"
    }
    
    weak var delegate: OpenClosedStatusManagerDelegate?
    
    private var timers: [(timer: Timer, itemID: String, fireDate: Date)] = []
    private var hasOpenClosedStatusDict: [String: any HasOpenClosedStatus] = [:]
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func registerTimers(for items: [any HasOpenClosedStatus]) {
        let now = Date()
        for item in items {
            var didScheduleTimer = true
            if let intervalContainingCurrentDate = item.hours.first(where: { $0.contains(now) }) {
                scheduleTimer(withInfo: (item.id, intervalContainingCurrentDate.end))
            } else if let nearestStartInterval = item.hours.first(where: { $0.start >= now }) {
                scheduleTimer(withInfo: (item.id, nearestStartInterval.start))
            } else if let nearestEndInterval = item.hours.first(where: { $0.end >= now }) {
                scheduleTimer(withInfo: (item.id, nearestEndInterval.end))
            } else {
                didScheduleTimer = false
            }
            
            if didScheduleTimer {
                hasOpenClosedStatusDict[item.id] = item
            } else {
                hasOpenClosedStatusDict.removeValue(forKey: item.id)
            }
        }
    }
    
    
    // MARK: - Private Methods

    @objc private func fireTimer(_ timer: Timer) {
        let itemID = (timer.userInfo as? [String: String])?[Constants.timerUserInfoKey] ?? ""
        delegate?.didTimerFire(for: itemID, with: timer)
        timer.invalidate()

        if let item = hasOpenClosedStatusDict[itemID] {
            registerTimers(for: [item])
        }
    }
    
    @objc private func appWillEnterForeground() {
        let hasOpenClosedStatusItems = Array(hasOpenClosedStatusDict.values)
        registerTimers(for: hasOpenClosedStatusItems)
    }

    @objc private func appDidEnterBackground() {
        invalidateTimers()
    }
    
    private func invalidateTimers() {
        timers.forEach { $0.timer.invalidate() }
        timers.removeAll()
    }
    
    private func scheduleTimers(withInfos timerInfos: [(itemID: String, fireDate: Date)]) {
        timerInfos.forEach { scheduleTimer(withInfo: $0) }
    }
    
    private func scheduleTimer(withInfo timerInfo: (itemID: String, fireDate: Date)) {
        let (itemID, fireDate) = timerInfo
        let t = Timer(timeInterval: max(0.01, fireDate.timeIntervalSinceNow),
                      target: self,
                      selector: #selector(fireTimer),
                      userInfo: [Constants.timerUserInfoKey: itemID],
                      repeats: false)
        t.tolerance = 0.5
        RunLoop.main.add(t, forMode: .default)
        timers.append((t, itemID, fireDate))
    }
}
