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

/// A search result linking a resource back to its category and section context.
struct BMResourceSearchResult: Identifiable {
    let id = UUID()
    let resource: BMResource
    let sectionTitle: String?
    let categoryName: String
}

/// Codable version of BMResourceSearchResult for persistence.
struct CodableResourceSearchResult: Codable {
    let resource: BMResource
    let sectionTitle: String?
    let categoryName: String

    init(from result: BMResourceSearchResult) {
        self.resource = result.resource
        self.sectionTitle = result.sectionTitle
        self.categoryName = result.categoryName
    }

    func toSearchResult() -> BMResourceSearchResult {
        BMResourceSearchResult(resource: resource, sectionTitle: sectionTitle, categoryName: categoryName)
    }
}


// MARK: - ResourcesViewModel 

class ResourcesViewModel: ObservableObject {
    @Published var resourceCategories = [BMResourceCategory]()
    @Published var isLoading = false
    @Published var alert: BMAlert?
    
    // Search state
    @Published var searchText = ""
    @Published var isSearching = false
    @Published var searchResults = [BMResourceSearchResult]()
    @Published var recentVisitedResources = [BMResourceSearchResult]()
    
    private static let maxRecentVisited = 3
    
    var resourceCategoryNames: [String] {
        resourceCategories.map { $0.name }
    }
    
    init() {
        recentVisitedResources = Self.loadRecentVisitedResources()
        isLoading = true
        Task {
            await fetchResourceCategories()
        }
    }
    
    // MARK: - Search
    
    func performSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }
        
        let lowercasedQuery = trimmed.lowercased()
        var results = [BMResourceSearchResult]()
        
        for category in resourceCategories {
            for section in category.sections {
                for resource in section.resources {
                    if resource.name.lowercased().contains(lowercasedQuery) {
                        results.append(BMResourceSearchResult(
                            resource: resource,
                            sectionTitle: section.title,
                            categoryName: category.name
                        ))
                    }
                }
            }
        }
        
        searchResults = results
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    func saveRecentVisitedResource(_ result: BMResourceSearchResult) {
        recentVisitedResources.removeAll { $0.resource.name == result.resource.name }
        recentVisitedResources.insert(result, at: 0)
        if recentVisitedResources.count > Self.maxRecentVisited {
            recentVisitedResources = Array(recentVisitedResources.prefix(Self.maxRecentVisited))
        }
        Self.persistRecentVisited(recentVisitedResources)
    }
    
    func clearAllRecentVisited() {
        recentVisitedResources.removeAll()
        Self.persistRecentVisited(recentVisitedResources)
    }
    
    private static func persistRecentVisited(_ resources: [BMResourceSearchResult]) {
        let codable = resources.map { CodableResourceSearchResult(from: $0) }
        if let data = try? JSONEncoder().encode(codable) {
            UserDefaults.standard.set(data, forKey: .recentVisitedResources)
        }
    }
    
    private static func loadRecentVisitedResources() -> [BMResourceSearchResult] {
        guard let data = UserDefaults.standard.data(forKey: .recentVisitedResources),
              let codable = try? JSONDecoder().decode([CodableResourceSearchResult].self, from: data) else {
            return []
        }
        return codable.map { $0.toSearchResult() }
    }
    
    // MARK: - Networking
    
    @MainActor
    private func fetchResourceCategories() async {
        do {
            defer {
                isLoading = false
            }
            let sortedCategories = try await BMNetworkingManager.shared.fetchResourcesCategories()
            resourceCategories = sortedCategories
        } catch {
            withoutAnimation {
                self.alert = BMAlert(title: "Failed To Fetch Resources", message: error.localizedDescription, type: .notice)
            }
        }
    }
}
