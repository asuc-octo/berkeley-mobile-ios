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
    @StateObject private var safetyViewModel = SafetyViewModel()
    @Namespace private var safetyLogDetailAnimation
    @State private var selectedSafetyLog: BMSafetyLog?
    @State private var drawerViewState = BMDrawerViewState.medium
    
    private var isPresentingSafetyLogDetailView: Bool {
        selectedSafetyLog != nil
    }
    
    var body: some View {
        ZStack {
            Group {
                SafetyMapView(selectedSafetyLog: $selectedSafetyLog)
                    .environmentObject(safetyViewModel)
                drawerView
            }
            .allowsHitTesting(isPresentingSafetyLogDetailView ? false : true)
            .blur(radius: isPresentingSafetyLogDetailView ? 40 : 0)
            
            if isPresentingSafetyLogDetailView {
                SafetyLogDetailView(selectedSafetyLog: $selectedSafetyLog)
                    .padding()
                    .matchedGeometryEffect(id: selectedSafetyLog!.id, in: safetyLogDetailAnimation)
            }
        }
        .animation(.easeInOut, value: isPresentingSafetyLogDetailView)
    }
    
    private var drawerView: some View {
        BMDrawerView(drawerViewState: $drawerViewState, hPadding: 16) {
            VStack(alignment: .leading) {
                alertsDrawerHeaderView
                
                if safetyViewModel.isFetchingLogs {
                    loadingSafetyLogsView
                } else {
                    if !safetyViewModel.filteredSafetyLogs.isEmpty {
                        List(safetyViewModel.filteredSafetyLogs, id: \.id) { safetyLog in
                            SafetyLogView(safetyLog: safetyLog, isPresentingFullScreen: false)
                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .onTapGesture {
                                    selectedSafetyLog = safetyLog
                                }
                                .matchedGeometryEffect(id: safetyLog.id, in: safetyLogDetailAnimation)
                                .environmentObject(safetyViewModel)
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
                if !safetyViewModel.filteredSafetyLogs.isEmpty {
                    Spacer()
                    Text("^[\(safetyViewModel.filteredSafetyLogs.count) Result](inflect: true)")
                        .font(Font(BMFont.regular(16)))
                        .foregroundStyle(.gray)
                }
                Spacer()
                SafetyLogFilterButton(safetyLogFilterStates: $safetyViewModel.selectedSafetyLogFilterStates)
            }
            filterStatesScrollView
        }
    }
    
    @ViewBuilder
    private var filterStatesScrollView: some View {
        if !safetyViewModel.selectedSafetyLogFilterStates.isEmpty {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(safetyViewModel.selectedSafetyLogFilterStates, id: \.id) { filterState in
                        HStack {
                            Text(filterState.rawValue.capitalized)
                                .font(Font(BMFont.regular(16)))
                                .foregroundStyle(.white)
                            Button(action: {
                                withAnimation {
                                    if let removeIndex = safetyViewModel.selectedSafetyLogFilterStates.firstIndex(of: filterState) {
                                        safetyViewModel.selectedSafetyLogFilterStates.remove(at: removeIndex)
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

