//
//  DiningHallsViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/7/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import Foundation
import MapKit
import Observation
import os

fileprivate let kDiningHallAdditionalDataEndpoint = "Dining Halls"
fileprivate let kDiningHallEndpoint = "Dining Halls V2"

@Observable
class DiningHallsViewModel {
    var diningHalls: [BMDiningHall] = []
    var selectedDiningHall: BMDiningHall?
    var isFetching = false
    
    private let db = Firestore.firestore()
    
    init() {
        isFetching = true
        Task { @MainActor in
            let diningHallsAdditionalDataDict = await fetchDiningHallsAdditionalData()
            diningHalls = await fetchDiningHalls(withAdditionalData: diningHallsAdditionalDataDict)
            
            await MainActor.run {
                self.isFetching = false
            }
        }
    }
    
    func fetchDiningHalls(withAdditionalData additionalDataDict: [String: BMDiningHallAdditionalData] = [:]) async -> [BMDiningHall] {
        do {
            let snap = try await db.collection(kDiningHallEndpoint).getDocuments()
            let halls: [BMDiningHallRepresentation] = try snap.documents.map {
                try $0.data(as: BMDiningHallDocument.self).diningHall
            }
            let diningHalls = halls.map {
                let additionalData = additionalDataDict[$0.name]
                return BMDiningHall(name: $0.name,
                             address: additionalData?.address,
                             phoneNumber: additionalData?.phoneNumber,
                             imageLink: additionalData?.pictureURL,
                             meals: $0.getMealsTypeDict(),
                             hours: $0.openHourPeriods,
                             latitude: additionalData?.latitude,
                             longitude: additionalData?.longitude)
            }
            
            return diningHalls
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
    
    func openDiningHallInMaps(for diningHall: BMDiningHall) {
        guard let latitude = diningHall.latitude, let longitude = diningHall.longitude else {
            return
        }
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = diningHall.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func callDiningHall(for diningHall: BMDiningHall) {
        guard let phoneNumber = diningHall.phoneNumber, let url = URL(string: "tel://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
