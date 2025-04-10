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

struct BMResourceShoutout: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var subtitle: String
    var creationDate: Date
    var url: URL?
}


// MARK: - ResourcesViewModel 

class ResourcesViewModel: ObservableObject {
    @Published var shoutouts = [BMResourceShoutout]()
    @Published var resourceCategories = [BMResourceCategory]()
    private let db = Firestore.firestore()
    
    var resourceCategoryNames: [String] {
        resourceCategories.map { $0.name }
    }
    
    init() {
        Task {
            async let shoutouts: () = fetchResourceShoutouts()
            async let categories: () = fetchResourceCategories()
            
            await shoutouts
            await categories
        }
    }
    
    @MainActor
    private func fetchResourceCategories() async {
        let collection = db.collection("Resource Categories")
        
        do {
            let querySnapshot = try await collection.getDocuments()
            let documents = querySnapshot.documents
            var fetchedResourceCategories = [BMResourceCategory]()
            fetchedResourceCategories = documents.compactMap { queryDocumentSnapshot -> BMResourceCategory? in
                try? queryDocumentSnapshot.data(as: BMResourceCategory.self)
            }
            fetchedResourceCategories.sort(by: { $0.name < $1.name })
            self.resourceCategories = fetchedResourceCategories
        } catch {
            print("Error getting document (Resource Categories): \(error)")
        }
    }
    
    @MainActor
    private func fetchResourceShoutouts() async {
        let collection = db.collection("Resource Shoutouts")
        
        do {
            let querySnapshot = try await collection.getDocuments()
            let documents = querySnapshot.documents
            var fetchedResourceShoutouts = [BMResourceShoutout]()
            fetchedResourceShoutouts = documents.compactMap { queryDocumentSnapshot -> BMResourceShoutout? in
                try? queryDocumentSnapshot.data(as: BMResourceShoutout.self)
            }
            fetchedResourceShoutouts.sort(by: { $0.creationDate < $1.creationDate })
            self.shoutouts = fetchedResourceShoutouts
        } catch {
            print("Error getting document (Resource Shoutouts): \(error)")
        }
    }
}
