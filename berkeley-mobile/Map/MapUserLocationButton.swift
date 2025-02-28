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
}

struct MapUserLocationButton: View {
    @EnvironmentObject var viewModel: MapUserLocationButtonViewModel
    
    var honeUserLocationCompletionHandler: () -> Void
    
    var body: some View {
        Button(action: {
            if !viewModel.isHomingInOnUserLocation {
                withAnimation {
                    viewModel.isHomingInOnUserLocation = true
                    honeUserLocationCompletionHandler()
                }
            }
        }) {
            Image(systemName: viewModel.isHomingInOnUserLocation ? "location.fill" : "location")
                .font(.system(size: 24))
        }
        .buttonStyle(HomeMapControlButtonStyle())
    }
}

#Preview {
    MapUserLocationButton {}
        .environmentObject(MapUserLocationButtonViewModel())
}
