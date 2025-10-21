//
//  DiningHallsViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/7/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import Foundation
import Observation
import os

fileprivate let kDiningHallAdditionalDataEndpoint = "Dining Halls"
fileprivate let kDiningHallEndpoint = "Dining Halls V2"

@Observable
class DiningHallsViewModel {
    var diningHalls: [BMDiningHall] = []
    var selectedDiningHall: BMDiningHall?
    var isFetching = false
    
    private let openClosedStatusManager = OpenClosedStatusManager()
    
    private let db = Firestore.firestore()
    private let placesToOmit = ["Bear Market", "Den"]
    
    
    init() {
        openClosedStatusManager.delegate = self
        isFetching = true
        Task { @MainActor in
            let diningHallsAdditionalDataDict = await fetchDiningHallsAdditionalData()
            diningHalls = await fetchDiningHalls(withAdditionalData: diningHallsAdditionalDataDict)
            diningHalls.forEach { openClosedStatusManager.registerTimer(for: $0) }
            isFetching = false
        }
    }
    
    func fetchDiningHalls(withAdditionalData additionalDataDict: [String: BMDiningHallAdditionalData] = [:]) async -> [BMDiningHall] {
        do {
            let snap = try await db.collection(kDiningHallEndpoint).getDocuments()
            let hallDocs: [BMDiningHallDocument] = try snap.documents.map {
                try $0.data(as: BMDiningHallDocument.self)
            }
            let diningHalls = hallDocs.map {
                let diningHallRep = $0.diningHall
                let additionalData = additionalDataDict[diningHallRep.name]
                var diningHall = BMDiningHall(name: diningHallRep.name,
                             address: additionalData?.address,
                             phoneNumber: additionalData?.phoneNumber,
                             imageLink: additionalData?.pictureURL,
                             meals: diningHallRep.getMealsTypeDict(),
                             hours: diningHallRep.openHourPeriods,
                             latitude: additionalData?.latitude,
                             longitude: additionalData?.longitude,
                             documentID: $0.id ?? "")
                diningHall.updateIsOpenStatus(Date())
                return diningHall
            }
            
            return diningHalls.filter { !placesToOmit.contains($0.name) }
        } catch {
            Logger.diningHallsViewModel.error("\(error)")
        }
        
        return []
    }
    
    private func fetchDiningHallsAdditionalData() async -> [String: BMDiningHallAdditionalData] {
        do {
            let snap = try await db.collection(kDiningHallAdditionalDataEndpoint).getDocuments()
            
            let additionalDatas: [BMDiningHallAdditionalData] = try snap.documents.map {
                try $0.data(as: BMDiningHallAdditionalData.self)
            }
            
            var additionalDataDict: [String: BMDiningHallAdditionalData] = [:]
            
            for additionalData in additionalDatas {
                additionalDataDict[additionalData.name] = additionalData
            }
            
            return additionalDataDict
        } catch {
            Logger.diningHallsViewModel.error("\(error)")
        }
        
        return [:]
    }
    
    func logOpenedDiningDetailViewAnalytics(for diningHallName: String) {
        Analytics.logEvent("opened_food", parameters: ["dining_location" : diningHallName])
    }
}


// MARK: - OpenClosedStatusManagerDelegate

extension DiningHallsViewModel: OpenClosedStatusManagerDelegate {
    func didTimerFire(for itemID: String, with timer: Timer) {
        guard let diningHallToUpdateIndex = diningHalls.firstIndex(where: { $0.id == itemID }) else {
            Logger.diningHallsViewModel.error("Unable to find dining hall update index with itemID: \(itemID)")
            return
        }
        
        var updatedDiningHall = diningHalls[diningHallToUpdateIndex]
        updatedDiningHall.updateIsOpenStatus(Date())
        diningHalls[diningHallToUpdateIndex] = updatedDiningHall
    }
}
