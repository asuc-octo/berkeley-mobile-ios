//
//  BMNetworkingManager.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import Foundation

class BMNetworkingManager {
    static let shared = BMNetworkingManager()
    
    private let db = Firestore.firestore()
    
    
    // MARK: - Safety
    
    func fetchSafetyLogs() async throws -> [BMSafetyLog] {
        let collection = db.collection(BMConstants.safetyLogsCollectionName)
        let querySnapshot = try await collection.getDocuments()
        let documents = querySnapshot.documents
        let safetyLogs = documents.compactMap { try? $0.data(as: BMSafetyLog.self) }.sorted(by: { $0.date > $1.date })
        return safetyLogs
    }
    
    
    // MARK: - Resources
    
    func fetchResourcesCategories() async throws -> [BMResourceCategory] {
        let collection = db.collection(BMConstants.resourceCategoriesCollectionName)
        let querySnapshot = try await collection.getDocuments()
        let documents = querySnapshot.documents
        let resourceCateogries = documents.compactMap { try? $0.data(as: BMResourceCategory.self) }.sorted(by: { $0.name > $1.name })
        return resourceCateogries
    }
}
