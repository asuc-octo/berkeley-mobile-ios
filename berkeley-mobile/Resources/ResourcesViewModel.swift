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
    @Published var isLoading = true
    private let db = Firestore.firestore()
        var resourceCategoryNames: [String] {
        resourceCategories.map { $0.name }
    }
    
    init() {
        Task {
            await fetchResourceCategories()
        }
    }
    
    @MainActor
    private func fetchResourceCategories() async {
        let collection = db.collection("Resource Categories")
        
        do {
            let querySnapshot = try await collection.getDocuments()
            let documents = querySnapshot.documents
            var fetchedResourceCategories = documents.compactMap { queryDocumentSnapshot -> BMResourceCategory? in
                try? queryDocumentSnapshot.data(as: BMResourceCategory.self)
            }
            fetchedResourceCategories.sort(by: { $0.name < $1.name })
            self.resourceCategories = fetchedResourceCategories
            self.isLoading = false
        }
    }
    
    private func fetchResourceShoutouts() {
        let db = Firestore.firestore()
        db.collection("Resource Shoutouts").getDocuments { querySnapshot, error in
            guard error == nil else {
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            var fetchedResourceShoutouts = [BMResourceShoutout]()
            fetchedResourceShoutouts = documents.compactMap { queryDocumentSnapshot -> BMResourceShoutout? in
                return try? queryDocumentSnapshot.data(as: BMResourceShoutout.self)
            }
            fetchedResourceShoutouts.sort(by: { $0.creationDate < $1.creationDate })
            self.shoutouts = fetchedResourceShoutouts
        } catch {
            print("Error getting document (Resource Categories): \(error)")
        }
    }
}
