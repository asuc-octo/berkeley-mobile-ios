//
//  ResourcesViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

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
    
    var resourceCategoryNames: [String] {
        resourceCategories.map { $0.name }
    }
    
    init() {
        isLoading = true
        Task {
            await fetchResourceCategories()
        }
    }
    
    @MainActor
    private func fetchResourceCategories() async {
        do {
            defer {
                isLoading = false
            }
            let sortedCategories = try await BMNetworkingManager.shared.fetchResourcesCategories()
            resourceCategories = sortedCategories
        } catch {}
    }
}
