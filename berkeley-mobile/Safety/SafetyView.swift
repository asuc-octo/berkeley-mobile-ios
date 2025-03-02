//
//  SafetyView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI
import MapKit

struct SafetyView: View {
    @StateObject private var safetyViewManager = SafetyViewManager()
    @Namespace private var safetyLogDetailAnimation
    @State private var selectedSafetyLog: BMSafetyLog?
    @State private var isPresentingSafetyLogDetailView = false
    @State var region = MKCoordinateRegion(
        center: CLLocation(latitude: CLLocationDegrees(exactly: 37.871684)!, longitude: CLLocationDegrees(-122.259934)).coordinate,
        span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    var body: some View {
        ZStack {
            Group {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: safetyViewManager.safetyLogs) { safetyLog in
                    MapPin(coordinate: safetyLog.coordinate)
                }
                .edgesIgnoringSafeArea(.all)
                drawerView
            }
            .allowsHitTesting(isPresentingSafetyLogDetailView ? false : true)
            .blur(radius: isPresentingSafetyLogDetailView ? 40 : 0)
            
            if isPresentingSafetyLogDetailView {
                SafetyLogDetailView(isPresentingSafetyLogDetailView: $isPresentingSafetyLogDetailView, selectedSafetyLog: selectedSafetyLog!)
                    .padding()
                    .matchedGeometryEffect(id: selectedSafetyLog!.id, in: safetyLogDetailAnimation)
            }
        }
    }
    
    private var drawerView: some View {
        BMDrawerView(horizontalPadding: 16) {
            VStack(alignment: .leading) {
                alertsDrawerHeaderView
                
                if safetyViewManager.isFetchingLogs {
                    loadingSafetyLogsView
                } else {
                    if !safetyViewManager.filteredSafetyLogs.isEmpty {
                        List(safetyViewManager.filteredSafetyLogs, id: \.id) { safetyLog in
                            SafetyLogView(safetyLog: safetyLog, isPresentingFullScreen: false)
                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .onTapGesture {
                                    withAnimation {
                                        selectedSafetyLog = safetyLog
                                        isPresentingSafetyLogDetailView.toggle()
                                    }
                                }
                                .matchedGeometryEffect(id: safetyLog.id, in: safetyLogDetailAnimation)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .transition(.scale)
                    } else {
                        emptySafetyLogsView
                    }
                }
            }
        }
    }
    
    private var alertsDrawerHeaderView: some View {
        VStack {
            HStack {
                Text("Alerts")
                    .font(Font(BMFont.regular(30)))
                    .bold()
                    .font(.title)
                Spacer()
                SafetyLogFilterButton(safetyLogFilterStates: $safetyViewManager.selectedSafetyLogFilterStates)
            }
            filterStatesScrollView
        }
    }
    
    @ViewBuilder
    private var filterStatesScrollView: some View {
        if !safetyViewManager.selectedSafetyLogFilterStates.isEmpty {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(safetyViewManager.selectedSafetyLogFilterStates, id: \.id) { filterState in
                        HStack {
                            Text(filterState.rawValue.capitalized)
                                .font(Font(BMFont.regular(16)))
                                .foregroundStyle(.white)
                            Button(action: {
                                withAnimation {
                                    if let removeIndex = safetyViewManager.selectedSafetyLogFilterStates.firstIndex(of: filterState) {
                                        safetyViewManager.selectedSafetyLogFilterStates.remove(at: removeIndex)
                                    }
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.regularMaterial)
                            }
                        }
                        .padding(8)
                        .background(.gray.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var loadingSafetyLogsView: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    ProgressView()
                        .controlSize(.regular)
                    Text("Loading ...")
                        .font(Font(BMFont.regular(16)))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            Spacer()
        }
    }
    
    private var emptySafetyLogsView: some View {
        HStack {
            Spacer()
            Text("No Available Results")
                .bold()
                .foregroundStyle(.gray)
                .font(.title)
            Spacer()
        }
        .padding(EdgeInsets(top: 50, leading: 0, bottom: 50, trailing: 0))
        .transition(.scale)
    }
}


// MARK: - SafetyLogFilterButton

struct SafetyLogFilterButton: View {
    @Binding var safetyLogFilterStates: [BMSafetyLogFilterState]
    
    var body: some View {
        Menu {
            Menu("Crime Type") {
                Button("Robbery", action: { addToSafetyLogFilterStates(for: .robbery)})
                Button("Aggravated Assault", action: { addToSafetyLogFilterStates(for: .aggravatedAssault )})
                Button("Burglary", action: { addToSafetyLogFilterStates(for: .burglary)})
                Button("Sexual Assault", action: {addToSafetyLogFilterStates(for: .sexualAssault)})
                Button("Others", action: {addToSafetyLogFilterStates(for: .others)})
            }
            Menu("When") {
                Button("Today", action: {addToSafetyLogFilterStates(for: .today)} )
                Button("This Week", action: {addToSafetyLogFilterStates(for: .thisWeek)} )
                Button("This Month", action: {addToSafetyLogFilterStates(for: .thisMonth)} )
                Button("This Year", action: {addToSafetyLogFilterStates(for: .thisYear)} )
            }
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.purple, lineWidth: 1.0)
                .background(RoundedRectangle(cornerRadius: 20).fill(.purple.opacity(0.6)))
                .frame(width: 90, height: 35)
                .overlay(
                    HStack {
                        Text("Filter")
                            .font(Font(BMFont.regular(18)))
                            .fontWeight(.bold)
                        Image(systemName: "chevron.down")
                    }
                    .foregroundStyle(.white)
                )
        }
        .menuOrder(.fixed)
    }
    
    private func addToSafetyLogFilterStates(for newFilterState: BMSafetyLogFilterState) {
        if !safetyLogFilterStates.contains(newFilterState) {
            withAnimation {
                self.safetyLogFilterStates.append(newFilterState)
            }
        }
    }
}

#Preview {
    SafetyView()
}

