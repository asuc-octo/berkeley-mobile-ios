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
                
                VStack(alignment: .leading, spacing: 8) {
                    headerView
                    descriptionView
                    infoRowView
                        .padding(.horizontal, 6)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .frame(minWidth: 100, maxHeight: 120)
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
                .frame(width: 16)
    }
    
    private var headerView: some View {
        HStack {
            Text(marker?.title ?? "Unknown")
                .font(Font(BMFont.bold(18)))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            
            Button {
                onClose?()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .padding(.trailing, 10)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
    
    private var descriptionView: some View {
        Text(marker?.subtitle ?? "No description")
            .font(Font(BMFont.regular(12)))
            .lineLimit(3)
            .minimumScaleFactor(0.6)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 6)
    }
    
    private var infoRowView: some View {
        HStack {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                openStatusButton
            }
            
            Spacer()
            
            locationInfoView
            
            Spacer()
            
            categoryView
        }
        .padding(.bottom, 6)
    }
    
    private var openStatusButton: some View {
        Group {
            Capsule()
                .fill(marker?.isOpen ?? false ? Color.blue : Color(red: 0.4, green: 0.5, blue: 0.9))
                .frame(width: 70, height: 28)
                .overlay {
                    Text(marker?.isOpen ?? false ? "Open" : "Closed")
                        .font(Font(BMFont.medium(14)))
                        .foregroundStyle(.white)
                }
        }
    }
    
    private var locationInfoView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 20))
                .foregroundColor(.secondary)
            Text(marker?.address ?? "No Address")
                .font(Font(BMFont.regular(12)))
                .foregroundColor(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
        }
    }
    
    private var categoryView: some View {
        HStack {
            Image(systemName: getCategoryIcon())
                .font(.system(size: 20))
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
            .minimumScaleFactor(0.7)
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
    

// MARK: - GIR Info View

    private var girInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                let accessibleGIRs = marker?.accessibleGIRs ?? []
                let nonAccessibleGIRs = marker?.nonAccessibleGIRs ?? []
                
                Text("Accessible:")
                    .font(Font(BMFont.bold(12)))
                
                Text(accessibleGIRs.isEmpty ? "None" : accessibleGIRs.joined(separator: ", "))
                    .font(Font(BMFont.light(12)))
                
                Text("Non-Accessible:")
                    .font(Font(BMFont.bold(12)))
                    .padding(.top, 4)
                
                Text(nonAccessibleGIRs.isEmpty ? "None" : nonAccessibleGIRs.joined(separator: ", "))
                    .font(Font(BMFont.light(12)))
            }
            .padding(.leading, 20)
        }
    }
    

// MARK: - MPD Info View

    private var mpdInfoView: some View {
        VStack {
            ForEach(marker?.mpdRooms ?? [], id: \.roomNumber) { room in
                Group {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Gender Type: \(room.bathroomType)")
                            .font(Font(BMFont.light(12)))
                        Text("Floor: \(room.floorName)")
                            .font(Font(BMFont.light(12)))
                        Text("Room Number: \(room.roomNumber)")
                            .font(Font(BMFont.light(12)))
                        Text("Products: \(room.productType)")
                            .font(Font(BMFont.light(12)))
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 8)
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {
    MapMarkerDetailSwiftView(
        marker: MapMarker(
            type: "Cafe",
            location: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934),
            name: "Golden Bear Cafe",
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
