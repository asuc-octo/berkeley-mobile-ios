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
    @Published var isLoading = true // Track loading state

    var resourceCategoryNames: [String] {
        resourceCategories.map { $0.name }
    }

    init() {
        loadResources()
    }

    private func loadResources() {
        isLoading = true
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        fetchResourceShoutouts {
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        fetchResourceCategories {
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }

    private func fetchResourceCategories(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("Resource Categories").getDocuments { querySnapshot, error in
            defer { completion() }
            guard error == nil, let documents = querySnapshot?.documents else { return }
            
            self.resourceCategories = documents.compactMap { try? $0.data(as: BMResourceCategory.self) }
                .sorted { $0.name < $1.name }
        }
    }

    private func fetchResourceShoutouts(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("Resource Shoutouts").getDocuments { querySnapshot, error in
            defer { completion() }
            guard error == nil, let documents = querySnapshot?.documents else { return }
            
            self.shoutouts = documents.compactMap { try? $0.data(as: BMResourceShoutout.self) }
                .sorted { $0.creationDate < $1.creationDate }
        }
    }
}
