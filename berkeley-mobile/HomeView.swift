//
//  HomeView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/1/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var isShowingDrawer = false
    @Published var isShowingHomeDrawerDetailView: (type: HomeDrawerViewType, item: SearchItem)? = nil
    
    enum HomeDrawerViewType {
        case dining
        case fitness
        case study
    }
    
    func presentDetail(type: AnyClass, item: SearchItem) {
        withAnimation {
            if type == DiningHall.self {
                isShowingHomeDrawerDetailView = (.dining, item)
            } else if type == Gym.self {
                isShowingHomeDrawerDetailView = (.fitness, item)
            } else if type == Library.self {
                isShowingHomeDrawerDetailView = (.study, item)
            } else {
                return
            }
        }
    }
}

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var tabSelectedIndex = 0
    @State private var selectedDetent: PresentationDetent = .fraction(0.45)
    
    private var mapViewController: MapViewController
    
    init() {
        let homeViewModel = HomeViewModel()
        let mapViewController = MapViewController()
        
        _homeViewModel = StateObject(wrappedValue: homeViewModel)
        
        mapViewController.homeViewModel = homeViewModel
        self.mapViewController = mapViewController
    }
    
    var body: some View {
        ZStack {
            HomeMapView(mapViewController: mapViewController)
                .ignoresSafeArea()
            VStack {
                if !homeViewModel.isShowingDrawer {
                    BMDrawerView {
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
        }
    }
    
    private var segmentedControlHeader: some View {
        SegmentedControlView(
            tabNames: ["Dining", "Fitness", "Study"],
            selectedTabIndex: $tabSelectedIndex
        )
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var homeDrawerBackButton: some View {
        Button(action: {
            withAnimation {
                homeViewModel.isShowingHomeDrawerDetailView = nil
            }
        }) {
            Image(systemName: "chevron.left.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.gray)
        }
    }
    
    private var homeDrawerHeaderView: some View {
        HStack {
            if homeViewModel.isShowingHomeDrawerDetailView != nil {
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
            if let detailViewInfo = homeViewModel.isShowingHomeDrawerDetailView {
                switch detailViewInfo.type {
                case .dining:
                    DiningDetailView(diningHall: detailViewInfo.item as! DiningHall)
                case .fitness:
                    GymDetailView(gym: detailViewInfo.item as! Gym)
                case .study:
                    LibraryDetailView(library: detailViewInfo.item as! Library)
                }
            } else {
                switch tabSelectedIndex {
                case 0:
                    DiningView(mapViewController:  mapViewController)
                case 1:
                    FitnessView(mapViewController: mapViewController)
                default:
                    StudyView(mapViewController: mapViewController)
                }
            }
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
