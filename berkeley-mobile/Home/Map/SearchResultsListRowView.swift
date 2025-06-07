//
//  SearchResultsListRowView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

// MARK: - SearchResultsListRowView

struct SearchResultsListRowView: View {
    let placemark: MapPlacemark
    
    var distance: Double? {
        guard let placemarkLocation = placemark.location else {
            return nil
        }
        
        return placemarkLocation.distanceFromUser()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "mappin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8)
                    .foregroundStyle(Color(BMColor.searchBarIconColor))
                
                if let distance {
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
            
            Spacer()
        }
        .padding(10)
        .frame(height: 60.0)
    }
}


// MARK: - RecentSearchListRowView

struct RecentSearchListRowView: View {
    var codablePlacemark: CodableMapPlacemark
    
    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .resizable()
                .scaledToFit()
                .frame(width: 24)
                .foregroundStyle(Color(BMColor.searchBarIconColor))
                .frame(width: 52)
            
            Text(codablePlacemark.searchName ?? "Not Available")
                .font(Font(BMFont.regular(16)))
                .frame(height: 36)
            
            Spacer()
        }
        .padding(10)
        .frame(height: 54.0)
    }
}

#Preview("SearchResultsListRowView") {
    let previewCoordinates = CLLocation(latitude: 37.87538, longitude: -122.25612109999999)
    let previewPlacemark = MapPlacemark(loc: previewCoordinates, name: "Foothill", locName: "2700 Hearst Ave, Berkeley, CA 94720")
    
    VStack {
        Button(action: {}) {
            SearchResultsListRowView(placemark: previewPlacemark)
        }
        .buttonStyle(SearchResultsListRowButtonStyle())
    }
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 12))
    .padding()
}

#Preview("RecentSearchListRowView") {
    let previewCodablePlacemark = CodableMapPlacemark(
        latitude: 37.87538,
        longitude: -122.25612109999999,
        searchName: "Foothill",
        locationName: "2700 Hearst Ave, Berkeley, CA 94720"
    )
    
    VStack {
        Button(action: {}) {
            RecentSearchListRowView(codablePlacemark: previewCodablePlacemark)
        }
        .buttonStyle(SearchResultsListRowButtonStyle())
    }
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 12))
    .padding()
}
