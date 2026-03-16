//
//  FitnessView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 6/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import FirebaseAnalytics
import SwiftUI
import WidgetKit

struct FitnessView: View {
    @InjectedObject(\.homeViewModel) private var homeViewModel
    @InjectedObject(\.rsfOccupancyViewModel) private var rsfOccupancyViewModel
    @InjectedObject(\.stadiumOccupancyViewModel) private var stadiumOccupancyViewModel

    var mapViewController: MapViewController
    
    var selectionHandler: ((BMGym) -> Void)?
    
    var body: some View {
        VStack(spacing: 15) {
            gymOccupancyGauges
            BMHomeSectionListView(sectionType: .fitness, items: homeViewModel.gyms, mapViewController: mapViewController) { selectedGym in
                selectionHandler?(selectedGym as! BMGym)
            } swipeActionsContent: { _ in }
        }
        .onAppear {
            WidgetCenter.shared.reloadTimelines(ofKind: "GymOccupancyWidget")
            Analytics.logEvent("opened_gym_screen", parameters: nil)
        }
    }
    
    private var gymOccupancyGauges: some View {
        HStack(spacing: 30){
            GymOccupancyView()
                .environmentObject(rsfOccupancyViewModel)
            GymOccupancyView()
                .environmentObject(stadiumOccupancyViewModel)
        }
    }
}

#Preview {
    FitnessView(mapViewController: MapViewController())
        .padding()
        .background(.blue.opacity(0.1))
}
