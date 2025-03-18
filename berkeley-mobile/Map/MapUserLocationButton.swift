//
//  MapUserLocationButton.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

class MapUserLocationButtonViewModel: ObservableObject {
    @Published var isHomingInOnUserLocation = false
    @Published var isUserLocationAvailable = false
    
    init() {
        BMLocationManager.notificationCenter.addObserver(
            self,
            selector: #selector(userLocationIsUpdated),
            name: .locationUpdated,
            object: nil
        )
    }
    
    @objc
    func userLocationIsUpdated() {
        withAnimation {
            isUserLocationAvailable = BMLocationManager.shared.userLocation != nil
        }
    }
}

struct MapUserLocationButton: View {
    @EnvironmentObject var viewModel: MapUserLocationButtonViewModel
    
    var homeInUserLocationCompletionHandler: () -> Void
    
    var body: some View {
        Button(action: {
            guard viewModel.isUserLocationAvailable else {
                BMLocationManager.shared.handleLocationAuthorization()
                return
            }
            
            if !viewModel.isHomingInOnUserLocation {
                withAnimation {
                    viewModel.isHomingInOnUserLocation = true
                    homeInUserLocationCompletionHandler()
                }
            }
        }) {
            if #available(iOS 17.0, *) {
                locationImage
                    .contentTransition (
                        .symbolEffect(.replace)
                    )
            } else {
                locationImage
            }
        }
        .buttonStyle(HomeMapControlButtonStyle())
    }
    
    @ViewBuilder
    private var locationImage: some View {
        let hasLocationSymbolName = viewModel.isHomingInOnUserLocation ? "location.fill" : "location"
        Image(systemName: viewModel.isUserLocationAvailable ? hasLocationSymbolName : "location.slash")
            .font(.system(size: 24))
            .opacity(viewModel.isUserLocationAvailable ? 1 : 0.6)
    }
}

#Preview {
    MapUserLocationButton {}
        .environmentObject(MapUserLocationButtonViewModel())
}
