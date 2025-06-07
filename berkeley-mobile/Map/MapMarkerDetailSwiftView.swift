//
//  MapMakerDetailSwiftView.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 3/11/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

struct MapMarkerDetailSwiftView: View {
    var marker: MapMarker?
    var onClose: (() -> Void)?
    
    var body: some View {
        HStack {
            colorAccentBar
            
            VStack(alignment: .leading, spacing: 4) {
                headerView
                Spacer()
                descriptionView
                Spacer()
                infoRowView                    
            }
            .padding(.vertical, 8)
            Spacer()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)
        .frame(minWidth: 200, maxHeight: 140)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    
    // MARK: - Private Views
    
    private var colorAccentBar: some View {
        Rectangle()
            .fill(getMarkerColor())
            .frame(width: 12)
    }
    
    private func getMarkerColor() -> Color {
        guard let marker else {
            return .purple
        }
        
        switch marker.type {
        case .known(let type):
            return Color(type.color())
        case .unknown:
            return Color(BMColor.MapMarker.other)
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            Text((marker?.title ?? "Unknown").capitalized)
                .font(Font(BMFont.bold(21)))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            
            Button(action: {
                onClose?()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.secondary)
                    .padding(.trailing, 4)
            }
        }
    }
    
    private var descriptionView: some View {
        Text(marker?.subtitle ?? "No description")
            .font(Font(BMFont.regular(10)))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.trailing, 8)
    }
    
    private var infoRowView: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .rotationEffect(.init(degrees: 90))
            openStatusButton
            
            Spacer()
            
            locationInfoView
            
            Spacer()
            
            categoryView
        }
    }
    
    private var openStatusButton: some View {
            Capsule()
                .fill(marker?.isOpen ?? false ? .blue : Color(red: 0.4, green: 0.5, blue: 0.9))
                .frame(width: 48, height: 18)
                .overlay {
                    Text(marker?.isOpen ?? false ? "Open" : "Closed")
                        .font(Font(BMFont.medium(9)))
                        .foregroundStyle(.white)
                }
    }
    
    private var locationInfoView: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(marker?.address ?? "No Address")
                .font(Font(BMFont.regular(12)))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
        }
    }
    
    private var categoryView: some View {
        HStack(spacing: 8){
            if let marker, case .known(let type) = marker.type {
                Image(uiImage: type.icon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "mappin")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Group {
                if let marker, case .known(let type) = marker.type, type == .cafe, let mealPrice = marker.mealPrice {
                    Text(mealPrice)
                }
            }
            .font(Font(BMFont.regular(12)))
            .foregroundColor(.primary)
        }
    }
}


// MARK: - Preview

#Preview {
    MapMarkerDetailSwiftView(
        marker: MapMarker(
            type: "Cafe",
            location: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934),
            name: "Babette South Hall Coffee Bar",
            description: "A retail Cal Dining location featuring a Peet Coffee & tea store, made- to-go order deli and bagels bar, smoothies, and grab-and-go items.",
            address: "Lower Sproul Plaza",
            onCampus: true,
            phone: "510-123-4567",
            email: "gbc@berkeley.edu",
            weeklyHours: nil,
            appointment: false,
            mealPrice: "$5-10",
            cal1Card: true,
            eatWell: true,
            mpdRooms: nil,
            accessibleGIRs: nil,
            nonAccesibleGIRs: nil
        ),
        onClose: {}
    )
}
