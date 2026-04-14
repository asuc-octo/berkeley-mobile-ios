//
//  HomeView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/1/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct HomeView: View {
    @Injected(\.menuItemIconCacheManager) private var menuItemIconCacheManager

    @InjectedObservable(\.diningHallsViewModel) private var diningHallsViewModel
    @InjectedObservable(\.guidesViewModel) private var guidesViewModel
    @InjectedObservable(\.homeDrawerPinViewModel) private var homeDrawerPinViewModel

    @InjectedObject(\.homeViewModel) private var homeViewModel

    @State private var navigationPath = NavigationPath()
    @State private var isPresentingDetailView = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.45)

    private var mapViewController: MapViewController
    
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
            .onChange(of: homeViewModel.isShowingDrawer) {
                homeViewModel.drawerViewState = .medium
            }
        }
    }
    
    private var segmentedControlHeader: some View {
        BMSegmentedControlView(
            tabNames: ["Dining", "Fitness", "Study", "Guides"],
            selectedTabIndex: $homeViewModel.tabSelectedIndex
        )
        .padding(.top, 20)
    }
    
    private var homeDrawerContentView: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if homeViewModel.isFetching {
                    ProgressView("LOADING")
                        .padding(.vertical, 20)
                    Spacer()
                } else {
                    segmentedControlHeader
                    switch homeViewModel.tabSelectedIndex {
                    case 0:
                        DiningHallsView(mapViewController: mapViewController) { selectedDiningHall in
                            navigationPath.append(selectedDiningHall)
                        }
                        .onAppear {
                            homeViewModel.logOpenedDiningHomeSectionAnalytics()
                        }
                    case 1:
                        FitnessView(mapViewController: mapViewController) { selectedGym in
                            navigationPath.append(selectedGym)
                        }
                    case 2:
                        LibrariesView(mapViewController: mapViewController) { selectedLibrary in
                            navigationPath.append(selectedLibrary)
                        }
                    default:
                        GuidesView()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .containerBackground(.clear, for: .navigation)
            .padding(.horizontal)
            .navigationDestination(for: BMDiningHall.self) { diningHall in
                DiningDetailView(diningHall: diningHall)
                    .containerBackground(.clear, for: .navigation)
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
}
