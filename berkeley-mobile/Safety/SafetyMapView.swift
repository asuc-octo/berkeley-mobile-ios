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
    @Binding var drawerViewState: BMDrawerViewState
    
    var body: some View {
        if #available(iOS 17.0, *) {
            SafetyNewMapView(selectedSafetyLog: $selectedSafetyLog, isShowingLegend: $isShowingLegend, drawerViewState: $drawerViewState)
        } else {
            oldMapView
        }
    }
    
    private var oldMapView: some View {
        Map(coordinateRegion: .constant(Constants.mapBoundsRegion), showsUserLocation: true, annotationItems: safetyViewModel.filteredSafetyLogs) { safetyLog in
            MapPin(coordinate: safetyLog.coordinate)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


// MARK: - SafetyNewMapView

@available(iOS 17.0, *)
struct SafetyNewMapView: View {
    @EnvironmentObject var safetyViewModel: SafetyViewModel
    
    @State private var mapCameraPosition = MapCameraPosition.automatic
    @State private var isShowingAllMarkers = true
    @State private var isZoomIn = true
    @Binding var selectedSafetyLog: BMSafetyLog?
    @Binding var isShowingLegend: Bool
    @Binding var drawerViewState: BMDrawerViewState
    
    private let bounds = MapCameraBounds(centerCoordinateBounds: Constants.mapBoundsRegion, maximumDistance: Constants.mapMaxZoomDistance)
    
    var body: some View {
        ZStack {
            Map(position: $mapCameraPosition, bounds: bounds, selection: $selectedSafetyLog) {
                ForEach(safetyViewModel.filteredSafetyLogs) { safetyLog in
                    let dateText = "\(safetyLog.date.formatted(date: .numeric, time: .shortened))"
                    let monogramText = "\(safetyLog.getSafetyLogState.rawValue.first!.uppercased())"
                    Marker(dateText, monogram: Text(monogramText), coordinate: safetyLog.coordinate)
                        .tint(safetyViewModel.crimeInfos[safetyLog.getSafetyLogState]?.color ?? .red)
                        .tag(safetyLog)
                }
            }
            .mapControlVisibility(.hidden)
            mapHUD
        }
        .onChange(of: selectedSafetyLog) { newLog in
            guard let newLog else {
                return
            }
            zoomToSafetyLog(newLog)
        }
        .onChange(of: safetyViewModel.filteredSafetyLogs) {
            withAnimation {
                mapCameraPosition = .automatic
            }
        }
    }
    
    @ViewBuilder
    private var mapHUD: some View {
        if !safetyViewModel.crimeInfos.isEmpty {
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    VStack {
                        if #available(iOS 17.0, *) {
                            mapLegendButton
                            .contentTransition(
                                .symbolEffect(.replace)
                            )
                        } else {
                            mapLegendButton
                        }
                        
                        if #available(iOS 17.0, *) {
                            mapZoomInButton
                            .contentTransition(
                                .symbolEffect(.replace)
                            )
                        } else {
                            mapZoomInButton
                        }
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
    
    private var mapZoomInButton: some View {
        Button(action: {
            withAnimation(.spring) {
                isZoomIn.toggle()
                mapCameraPosition = .region(Constants.berkeleyRegion)
                drawerViewState = .small
            }
        }) {
            Image(systemName: "scope")
        }
        .symbolEffect(.bounce, value: isZoomIn)
        .buttonStyle(BMControlButtonStyle())
    }
    
    private var mapLegend: some View {
        VStack(alignment: .leading) {
            let crimeTypes = safetyViewModel.crimeInfos.keys.sorted(by: { $0.rawValue < $1.rawValue })
            
            ForEach(crimeTypes, id: \.self) { crimeType in
                if let crimeInfo = safetyViewModel.crimeInfos[crimeType] {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(crimeInfo.color)
                            .frame(width: 10, height: 10)
                        Text(crimeType.rawValue.capitalized)
                        Spacer()
                        Text("\(crimeInfo.count)")
                            .foregroundStyle(.gray)
                    }
                    .font(Font(BMFont.regular(18)))
                }
            }
        }
        .frame(width: 250)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .transition(.scale)
    }
    
    private func zoomToSafetyLog(_ log: BMSafetyLog) {
        let region = MKCoordinateRegion(
            center: log.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapCameraPosition = .region(region)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var drawerViewState = BMDrawerViewState.medium
    SafetyMapView(selectedSafetyLog: .constant(nil), drawerViewState: $drawerViewState)
        .environmentObject(SafetyViewModel())
}
