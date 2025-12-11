//
//  HomeDrawerPinViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import os

/// `HomeDrawerPinViewModel` keeps track of all the pinned row items in the Home Drawer
@Observable
class HomeDrawerPinViewModel {
    // Each String ID should be the Firebase Document ID of the pinned row item
    private(set) var pinnedRowItemIDSet = Set<String>()
    
    init() {
        retrievePinnedRowItemIDs()
    }
    
    func addPinnedRowItem(withID id: String) {
        pinnedRowItemIDSet.insert(id)
        savePinnedRowItemIDs()
    }
    
    func removePinnedRowItem(withID id: String) {
        pinnedRowItemIDSet.remove(id)
        savePinnedRowItemIDs()
    }
    
    private func retrievePinnedRowItemIDs() {
        guard let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.homeDrawerPinnedItemIDs) else {
            return
        }
        
        let decodedPinnedRowItemIDs = NSArray.unsecureUnarchived(from: decodedData) as? [String] ?? []
        decodedPinnedRowItemIDs.forEach { pinnedRowItemIDSet.insert($0) }
    }
    
    private func savePinnedRowItemIDs() {
        do {
            let ids = Array(pinnedRowItemIDSet)
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: ids, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.homeDrawerPinnedItemIDs)
        } catch {
            Logger.homeDrawerPinViewModel.error("Failed to save pinned row item ids: \(error.localizedDescription)")
        }
    }
}
