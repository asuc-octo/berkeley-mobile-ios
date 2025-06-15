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
                    BMDrawerView(drawerViewState: $homeViewModel.drawerViewState) {
                        VStack {
                            homeDrawerHeaderView
                            homeDrawerContentView
                        }
                        .ignoresSafeArea()
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
    
    private var homeDrawerBackButton: some View {
        Button(action: {
            withAnimation {
                homeViewModel.homeDrawerDetailViewInfo = nil
                mapViewController.handleDrawerDismissal()
            }
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.gray)
        }
    }
    
    private var homeDrawerHeaderView: some View {
        HStack {
            if homeViewModel.homeDrawerDetailViewInfo != nil {
                homeDrawerBackButton
                    .padding(.leading)
                Spacer()
            } else {
                segmentedControlHeader
            }
        }
    }
    
    private var homeDrawerContentView: some View {
        Group {
            if let detailViewInfo = homeViewModel.homeDrawerDetailViewInfo {
                switch detailViewInfo.type {
                case .dining:
                    DiningDetailView(diningHall: detailViewInfo.item as! DiningHall)
                case .fitness:
                    GymDetailView(gym: detailViewInfo.item as! BMGym)
                case .study:
                    LibraryDetailView(library: detailViewInfo.item as! BMLibrary)
                }
            } else {
                if homeViewModel.isFetching {
                    ProgressView("LOADING")
                } else {
                    switch tabSelectedIndex {
                    case 0:
                        BMHomeSectionListView(sectionType: .dining, items: homeViewModel.diningHalls, mapViewController: mapViewController)
                            .onAppear {
                                homeViewModel.logOpenedDiningHomeSectionAnalytics()
                            }
                    case 1:
                        FitnessView(mapViewController: mapViewController)
                            .environmentObject(homeViewModel)
                    default:
                        BMHomeSectionListView(sectionType: .study, items: homeViewModel.libraries, mapViewController: mapViewController)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    HomeView(mapViewController: MapViewController())
        .environmentObject(HomeViewModel())
}
