//
//  SafetyLogDetailView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 11/18/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

struct SafetyLogDetailView: View {
    @EnvironmentObject var safetyViewModel: SafetyViewModel
    
    @Binding var selectedSafetyLog: BMSafetyLog?
    @Binding var drawerViewState: BMDrawerViewState
    
    var body: some View {
        VStack {
            HStack {
                closeButton
                Spacer()
            }
            .padding(.bottom, 10)
            
            ScrollView(.vertical) {
                if let selectedSafetyLog = selectedSafetyLog {
                    let mapRegion = MKCoordinateRegion(center: selectedSafetyLog.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    Group {
                        if #available(iOS 17.0, *) {
                            Map(bounds: MapCameraBounds(centerCoordinateBounds: mapRegion, minimumDistance: 2000)) {
                                BMSafetyMapMarker(safetyLog: selectedSafetyLog)
                            }
                        } else {
                            Map(coordinateRegion: .constant(mapRegion), annotationItems: [selectedSafetyLog]) { safetyLog in
                                MapPin(coordinate: safetyLog.coordinate)
                            }
                        }
                    }
                    .allowsHitTesting(false)
                    .frame(height: 250)
                    .frame(minWidth: 300, maxWidth: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .gray.opacity(0.5), radius: 7)
                    .padding()
                    
                    SafetyLogView(safetyLog: selectedSafetyLog, isPresentingFullScreen: true)
                }
            }
        }
    }
    
    private var closeButton: some View {
        Button(action: {
            withAnimation {
                drawerViewState = .small
                selectedSafetyLog = nil
            }
        }) {
            // TODO: Make into own custom view if future calls
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 35))
                .foregroundStyle(.gray)
        }
    }
}


// MARK: - SafetyLogView

struct SafetyLogView: View {
    @EnvironmentObject private var viewModel: SafetyViewModel
    
    var safetyLog: BMSafetyLog
    var isPresentingFullScreen: Bool
    
    var body: some View {
        if isPresentingFullScreen {
            mainBody
        } else {
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.crimeInfos[safetyLog.getSafetyLogState]?.color ?? .gray.opacity(0.6), lineWidth: 1)
                .frame(minWidth: 300, maxWidth: 500, minHeight: 200)
                .overlay(
                    mainBody
                )
                .padding()
        }
    }
    
    private var mainBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                logTitle
                logDateAndTime
                logLocationView
            }
            Text(safetyLog.detail)
                .font(Font(BMFont.regular(12)))
                .font(.caption)
                .foregroundStyle(.secondary)
           
        }
        .padding()
    }
    
    private var logTitle: some View {
        HStack {
            Text(safetyLog.crime.capitalized)
                .font(Font(BMFont.regular(23)))
                .bold()
                .font(.title2)
            Spacer()
        }
    }
    
    @ViewBuilder
    private var logDateAndTime: some View {
        Text(getSafetyLogDateString())
            .font(Font(BMFont.regular(17)))
            .font(.subheadline)
    }
    
    private var logLocationView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text(safetyLog.location.capitalized)
                .font(Font(BMFont.regular(14)))
                .font(.caption)
                .bold()
        }
        .foregroundStyle(.green)
        
    }
    
    private func getSafetyLogDateString() -> String {
        let date = safetyLog.date
        let dayOfTheWeek = DayOfWeek.weekday(date)
        
        if date.isWithinPastWeek() {
            return "\(dayOfTheWeek.stringRepresentation(includesYesterdayTodayVerbage: true)) at \(date.formatted(date: .omitted, time: .shortened))"
        }
        
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

#Preview("SafetyLogDetailView") {
    SafetyLogDetailView(selectedSafetyLog: .constant(SafetyViewModel.getSampleSafetyLog()), drawerViewState: .constant(.small))
        .padding()
        .environmentObject(SafetyViewModel())
}

#Preview("SafetyLogView") {
    SafetyLogView(safetyLog: SafetyViewModel.getSampleSafetyLog(), isPresentingFullScreen: false)
        .padding()
        .environmentObject(SafetyViewModel())
}
