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

/// `OpenClosedStatusTimerSaveInfo` contains the information for a timer when the app enters the background and is retrieved the next time the app enters the foreground.
 struct OpenClosedStatusTimerSaveInfo: Codable, Equatable {
    let targetDate: Date
    let itemID: String
}

/// `OpenClosedStatusManager` manages associated `Timer` objects and callbacks to Home Drawer row items that conform to `HasOpenClosedStatus` for observation.
class OpenClosedStatusManager {
    private struct Constants {
        static let timerUserInfoKey = "item"
    }
    
    weak var delegate: OpenClosedStatusManagerDelegate?

    private var timers: [(timer: Timer, saveInfo: OpenClosedStatusTimerSaveInfo)] = []
    private var timerSaveInfos: [OpenClosedStatusTimerSaveInfo] {
        return timers.map { $0.saveInfo }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func registerTimer(for item: any HasOpenClosedStatus) {
        let startReps = item.hours.map { OpenClosedStatusTimerSaveInfo(targetDate: $0.start, itemID: item.id) }
        let endReps = item.hours.map { OpenClosedStatusTimerSaveInfo(targetDate: $0.end, itemID: item.id) }
        scheduleTimers(for: startReps + endReps)
    }
    
    @objc private func fireTimer(timer: Timer) {
        guard let context = timer.userInfo as? [String: OpenClosedStatusTimerSaveInfo], let item = context[Constants.timerUserInfoKey] else {
            return
        }
        delegate?.didTimerFire(for: item.itemID, with: timer)
        timer.invalidate()
    }
    
    @objc private func appWillEnterForeground() {
        guard let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.openClosedStatusTimerEndDates) else {
            return
        }
        
        do {
            let decodedInfos = try JSONDecoder().decode([OpenClosedStatusTimerSaveInfo].self, from: decodedData)

            saveTimers(for: decodedInfos)
            scheduleTimers(for: decodedInfos)
        } catch {
            Logger.openClosedStatusManager.error("Unable to retrieve timers: \(error)")
        }
    }
    
    @objc private func appDidEnterBackground() {
        let reps = timers.map { OpenClosedStatusTimerSaveInfo(targetDate: $0.timer.fireDate, itemID: $0.saveInfo.itemID) }
        timers.forEach { $0.timer.invalidate() }
        saveTimers(for: reps)
    }
    
    private func saveTimers(for saveInfos: [OpenClosedStatusTimerSaveInfo]) {
        let validSaveInfos = saveInfos.filter { $0.targetDate >= Date() }
        
        do {
            let encodedData = try JSONEncoder().encode(validSaveInfos)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.openClosedStatusTimerEndDates)
            timers = []
        } catch {
            Logger.openClosedStatusManager.error("Unable to save timers: \(error)")
        }
    }
    
    private func scheduleTimers(for saveInfos: [OpenClosedStatusTimerSaveInfo]) {
        let validSaveInfos = saveInfos.filter { $0.targetDate >= Date() }
        
        validSaveInfos.forEach {
            let newSaveInfo = OpenClosedStatusTimerSaveInfo(targetDate: $0.targetDate, itemID: $0.itemID)
            
            if !timerSaveInfos.contains(newSaveInfo) {
                let elapsed = $0.targetDate.timeIntervalSinceNow
                let timer = Timer(timeInterval: elapsed, target: self, selector: #selector(fireTimer), userInfo: [Constants.timerUserInfoKey: newSaveInfo], repeats: false)
                RunLoop.main.add(timer, forMode: .common)
                timers.append((timer, newSaveInfo))
            }
        }
    }
}
