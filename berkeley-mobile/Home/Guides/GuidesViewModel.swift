//
//  GuidesViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import Foundation
import os

fileprivate let kGuidesEndpoint = "Guides"

@Observable
class GuidesViewModel {
    var guides: [Guide] = []
    var isLoading = false
    
    private let db = Firestore.firestore()
    private let redirectionManager = RedirectionManager()
    
    init() {
        Task { @MainActor in
            isLoading = true
            let guides = await fetchGuides()
            self.guides = guides
            isLoading = false
        }
    }
    
    func fetchGuides() async -> [Guide] {
        do {
            let snap = try await db.collection(kGuidesEndpoint).getDocuments()
            let guides: [Guide] = snap.documents.compactMap {
                do {
                    return try $0.data(as: Guide.self)
                } catch {
                    Logger.guidesViewModel.error("Failed to decode guide: \(error)")
                    return nil
                }
            }
            return guides
        } catch {
            Logger.guidesViewModel.error("\(error)")
        }
        return []
    }
    
    func call(_ place: GuidePlace) {
        redirectionManager.call(place)
    }
    
    func openPlaceInMaps(for place: GuidePlace) {
        redirectionManager.openInMaps(for: place, withName: place.name)
    }
}
