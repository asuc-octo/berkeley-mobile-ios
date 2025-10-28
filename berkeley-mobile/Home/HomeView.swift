//
//  HomeView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/1/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    @State private var tabSelectedIndex = 0
    @State private var navigationPath = NavigationPath()
    @State private var isPresentingDetailView = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.45)
    
    private var mapViewController: MapViewController
    
    @State private var diningHallsViewModel = DiningHallsViewModel()
    private let menuIconCacheManager = MenuItemIconCacheManager()
    
    init(mapViewController: MapViewController) {
        self.mapViewController = mapViewController
    }
    
    var body: some View {
        ZStack {
            HomeMapView(mapViewController: mapViewController)
                .ignoresSafeArea()
            VStack {
                if homeViewModel.isShowingDrawer {
                    BMDrawerView(drawerViewState: $homeViewModel.drawerViewState, hPadding: 0, vPadding: 0) {
                        homeDrawerContentView
                    }
                    .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.default, value: homeViewModel.isShowingDrawer)
            .onChange(of: homeViewModel.isShowingDrawer) { _ in
                homeViewModel.drawerViewState = .medium
            }
        }
    }
    
    private var segmentedControlHeader: some View {
        BMSegmentedControlView(
            tabNames: ["Dining", "Fitness", "Study"],
            selectedTabIndex: $tabSelectedIndex
        )
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var homeDrawerContentView: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if homeViewModel.isFetching {
                    ProgressView("LOADING")
                        .padding()
                    Spacer()
                } else {
                    segmentedControlHeader
                    switch tabSelectedIndex {
                    case 0:
                        DiningHallsView(mapViewController: mapViewController) { selectedDiningHall in
                            navigationPath.append(selectedDiningHall)
                        }
                        .environment(diningHallsViewModel)
                        .onAppear {
                            homeViewModel.logOpenedDiningHomeSectionAnalytics()
                        }
                    case 1:
                        FitnessView(mapViewController: mapViewController) { selectedGym in
                            navigationPath.append(selectedGym)
                        }
                        .environmentObject(homeViewModel)
                    default:
                        LibrariesView(mapViewController: mapViewController) { selectedLibrary in
                            navigationPath.append(selectedLibrary)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .containerBackground(.clear, for: .navigation)
            .padding()
            .navigationDestination(for: BMDiningHall.self) { diningHall in
                DiningDetailView(diningHall: diningHall)
                    .containerBackground(.clear, for: .navigation)
                    .environment(diningHallsViewModel)
                    .environment(\.menuIconCache, menuIconCacheManager)
            }
            .navigationDestination(for: BMGym.self) { gym in
                GymDetailView(gym: gym)
                    .containerBackground(.clear, for: .navigation)
            }
            .navigationDestination(for: BMLibrary.self) { library in
                LibraryDetailView(library: library)
                    .containerBackground(.clear, for: .navigation)
            }
        }
    }
}

#Preview {
    HomeView(mapViewController: MapViewController())
        .environmentObject(HomeViewModel())
}
