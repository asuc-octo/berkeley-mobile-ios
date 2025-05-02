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

// MARK: - MapMarkerDetailSwiftView

struct MapMarkerDetailSwiftView: View {
    var marker: MapMarker?
    var onClose: (() -> Void)?
    var body: some View {
        ZStack {
            HStack {
                colorAccentBar
                
                VStack(alignment: .leading, spacing: 4) {
                    headerView
                    Spacer()
                    descriptionView
                    Spacer()
                    infoRowView
                        .padding([.trailing], 8)
                    
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                Spacer()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .frame(minWidth: 200, maxHeight: 140)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
    
    
    // MARK: - Private Views
    
    private var colorAccentBar: some View {
        let markerColor: Color = {
            guard let marker else {
                return .purple
            }
            
            switch marker.type {
            case .known(let type):
                return Color(type.color())
            case .unknown:
                return Color(BMColor.MapMarker.other)
            }
        }()
        
        return Rectangle()
            .fill(markerColor)
            .frame(width: 12)
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            Text((marker?.title ?? "Unknown").capitalized)
                .font(Font(BMFont.bold(21)))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            
            Button {
                onClose?()
            } label: {
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
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .rotationEffect(.init(degrees: 90))
                openStatusButton
            }
            
            Spacer()
            
            locationInfoView
            
            Spacer()
            
            categoryView
        }
    }
    
    private var openStatusButton: some View {
        HStack(spacing: 6){
            Capsule()
                .fill(marker?.isOpen ?? false ? Color.blue : Color(red: 0.4, green: 0.5, blue: 0.9))
                .frame(width: 48, height: 18)
                .overlay {
                    Text(marker?.isOpen ?? false ? "Open" : "Closed")
                        .font(Font(BMFont.medium(9)))
                        .foregroundStyle(.white)
                }
        }
    }
    
    private var locationInfoView: some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(marker?.address ?? "No Address")
                .font(Font(BMFont.regular(12)))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
    
    private var categoryView: some View {
        HStack(spacing: 6){
            Image(systemName: getCategoryIcon())
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Group {
                if let marker, case .known(let type) = marker.type, type == .cafe, let mealPrice = marker.mealPrice {
                    Text(mealPrice)
                        .font(Font(BMFont.regular(12)))
                        .foregroundColor(.primary)
                } else {
                    Text("<10")
                        .font(Font(BMFont.regular(12)))
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func getCategoryIcon() -> String {
        guard let marker else {
            return "questionmark.circle"
        }
        
        switch marker.type {
        case .known(let type):
            switch type {
            case .cafe:
                return "fork.knife"
            case .store:
                return "bag"
            case .mentalHealth:
                return "brain"
            case .genderInclusiveRestrooms:
                return "toilet"
            case .menstrualProductDispensers:
                return "drop"
            case .garden:
                return "leaf"
            case .bikes:
                return "bicycle"
            case .lactation:
                return "heart"
            case .rest:
                return "bed.double"
            case .microwave:
                return "bolt"
            case .printer:
                return "printer"
            case .water:
                return "drop.fill"
            case .waste:
                return "trash"
            case .none:
                return "mappin"
            }
        case .unknown:
            return "mappin"
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
