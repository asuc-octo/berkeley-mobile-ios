//
//  SafetyMapView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/10/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

struct SafetyMapView: View {
    @EnvironmentObject var safetyViewModel: SafetyViewModel
    
    @State private var isShowingLegend = false
    @Binding var selectedSafetyLog: BMSafetyLog?
    
    private let region = MKCoordinateRegion(
        center: CLLocation(latitude: CLLocationDegrees(exactly: 37.871684)!, longitude: CLLocationDegrees(-122.259934)).coordinate,
        span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    var body: some View {
        if #available(iOS 17.0, *) {
            let initialPosition = MapCameraPosition.region(region)
            ZStack {
                Map(initialPosition: initialPosition, selection: $selectedSafetyLog) {
                    ForEach(safetyViewModel.filteredSafetyLogs) { safetyLog in
                        let dateText = "\(safetyLog.date.formatted(date: .numeric, time: .shortened))"
                        let monogramText = "\(safetyLog.crime.first!.uppercased())"
                        Marker(dateText, monogram: Text(monogramText), coordinate: safetyLog.coordinate)
                            .tint(safetyViewModel.crimeColors[safetyLog.getSafetyLogState.rawValue] ?? .red)
                            .tag(safetyLog)
                    }
                }
                .mapControls {
                    MapCompass()
                }
                mapHUD
            }
        } else {
            oldMapView
        }
    }
    
    private var oldMapView: some View {
        Map(coordinateRegion: .constant(region), showsUserLocation: true, annotationItems: safetyViewModel.filteredSafetyLogs) { safetyLog in
            MapPin(coordinate: safetyLog.coordinate)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    private var mapHUD: some View {
        if !safetyViewModel.crimeColors.isEmpty {
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    if #available(iOS 17.0, *) {
                        mapLegendButton
                        .contentTransition(
                            .symbolEffect(.replace)
                        )
                    } else {
                        mapLegendButton
                    }
                    
                    if isShowingLegend {
                        mapLegend
                            .shadow(color: .gray, radius: 10)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
    
    private var mapLegendButton: some View {
        Button(action: {
            withAnimation(.spring) {
                isShowingLegend.toggle()
            }
        }) {
            Image(systemName: isShowingLegend ? "xmark" : "list.bullet")
                .font(.system(size: 20))
                .fontWeight(.semibold)
        }
        .buttonStyle(BMControlButtonStyle())
        .transition(.scale)
    }
    
    private var mapLegend: some View {
        VStack(alignment: .leading) {
            let crimeNames = safetyViewModel.crimeColors.keys.sorted(by: { $0 < $1 })
            ForEach(crimeNames, id: \.self) { crimeName in
                HStack(spacing: 10) {
                    Circle()
                        .fill(safetyViewModel.crimeColors[crimeName] ?? .red)
                        .frame(width: 10, height: 10)
                    Text(crimeName.capitalized)
                        .font(Font(BMFont.regular(18)))
                    Spacer()
                }
            }
        }
        .frame(width: 250)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .transition(.scale)
    }
}

#Preview {
    SafetyMapView(selectedSafetyLog: .constant(nil))
        .environmentObject(SafetyViewModel())
}
