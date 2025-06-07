//
//  HomeViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 6/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//
import SwiftUI

enum HomeDrawerViewType {
    case dining
    case fitness
    case study
    
    func getSectionInfo() -> (title: String, systemName: String) {
        switch self {
        case .dining:
            return (BMConstants.diningSectionTitle, "fork.knife")
        case .fitness:
            return (BMConstants.fitnessSectionTitle, "figure.run")
        case .study:
            return (BMConstants.studySectionTitle, "book")
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var isShowingDrawer = true
    @Published var homeDrawerDetailViewInfo: (type: HomeDrawerViewType, item: SearchItem)? = nil
    @Published var drawerViewState = BMDrawerViewState.medium
    
    @Published var isFetching = false
    @Published var diningHalls: [BMDiningLocation] = []
    @Published var libraries: [BMLibrary] = []
    @Published var gyms: [BMGym] = []
    
    let rsfOccupancyViewModel = GymOccupancyViewModel(location: .rsf)
    let stadiumOccupancyViewModel = GymOccupancyViewModel(location: .stadium)
    
    init() {
        fetchHomeSectionsData()
    }
    
    func presentDetail(type: AnyClass, item: SearchItem) {
        withAnimation {
            if type == DiningHall.self {
                homeDrawerDetailViewInfo = (.dining, item)
            } else if type == BMGym.self {
                homeDrawerDetailViewInfo = (.fitness, item)
            } else if type == BMLibrary.self {
                homeDrawerDetailViewInfo = (.study, item)
            } else {
                return
            }
            drawerViewState = .small
        }
    }
    
    private func fetchHomeSectionsData() {
        let group = DispatchGroup()
        
        isFetching = true

        group.enter()
        DataManager.shared.fetch(source: DiningHallDataSource.self) { diningLocations in
            self.diningHalls = diningLocations as? [BMDiningLocation] ?? []
            group.leave()
        }

        group.enter()
        DataManager.shared.fetch(source: LibraryDataSource.self) { libraries in
            self.libraries = libraries as? [BMLibrary] ?? []
            group.leave()
        }
        
        group.enter()
        DataManager.shared.fetch(source: GymDataSource.self) { gyms in
            self.gyms = gyms as? [BMGym] ?? []
            group.leave()
        }

        group.notify(queue: .main) {
            self.isFetching = false
        }
    }
}
