//
//  SearchResultsListRowView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

struct SearchResultsListRowView: View {
    let placemark: MapPlacemark

    var distance: Double? {
        guard
            let userLocation = LocationManager.shared.userLocation,
            let placemarkLocation = placemark.location
        else {
            return nil
        }
        
        return round(userLocation.distance(from: placemarkLocation) / 1600.0 * 10) / 10
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "mappin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8)
                    .foregroundStyle(Color(BMColor.searchBarIconColor))
                
                if let distance { // If user location is unavailable, then we don't show the distance
                    Text("\(distance, specifier: "%.1f") mi")
                        .font(Font(BMFont.regular(12)))
                }
            }
            .frame(width: 52)
            
            VStack(alignment: .leading) {
                Text(placemark.searchName ?? "Not Available")
                    .font(Font(BMFont.regular(16)))
                
                Text(placemark.locationName ?? "Not Available")
                    .font(Font(BMFont.regular(14)))
            }
            .frame(height: 36)
            
            Spacer() // To push stuff to the leading edge.
        }
        .padding(10)
        .frame(height: 60.0)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let previewCoordinates = CLLocation(latitude: 37.87538, longitude: -122.25612109999999)
    let previewPlacemark = MapPlacemark(loc: previewCoordinates, name: "Foothill", locName: "2700 Hearst Ave, Berkeley, CA 94720")
    
    return SearchResultsListRowView(placemark: previewPlacemark)
}
