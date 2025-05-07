//
//  ResourcesViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI
import Firebase

struct BMResourceCategory: Codable {
    var name: String
    var sections: [BMResourceSection]
}

struct BMResource: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var url: URL?
}

struct BMResourceSection: Hashable, Codable {
    var title: String?
    var resources: [BMResource]
}


// MARK: - ResourcesViewModel 

class ResourcesViewModel: ObservableObject {
    @Published var resourceCategories = [BMResourceCategory]()
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    var resourceCategoryNames: [String] {
        resourceCategories.map { $0.name }
    }
    
    init() {
        Task {
            await fetchResourceCategories()
        }
    }
    
    private func fetchResourceCategories() async {
        let collection = db.collection("Resource Categories")
        
        do {
            isLoading = true
            let querySnapshot = try await collection.getDocuments()
            let documents = querySnapshot.documents
            let fetchedResourceCategories = documents.compactMap { queryDocumentSnapshot -> BMResourceCategory? in
                try? queryDocumentSnapshot.data(as: BMResourceCategory.self)
            }
            
            let sortedCategories = fetchedResourceCategories.sorted { $0.name < $1.name }
            await MainActor.run {
                self.resourceCategories = sortedCategories
                self.isLoading = false
            }
        } catch {
            print("Error getting document (Resource Categories): \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
