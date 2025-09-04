//
//  SafetyView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

struct SafetyView: View {
    @StateObject private var safetyViewModel = SafetyViewModel()
    @State private var selectedSafetyLog: BMSafetyLog?
    @State private var drawerViewState = BMDrawerViewState.medium
    
    private var isPresentingSafetyLogDetailView: Bool {
        selectedSafetyLog != nil
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            NavigationStack {
                safetyContentView
                .toolbar {
                    if isPresentingSafetyLogDetailView {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(role: .cancel) {
                                drawerViewState = .small
                                selectedSafetyLog = nil
                            }
                        }
                    }
                }
            }
        } else {
            safetyContentView
        }
    }
    
    private var safetyContentView: some View {
        ZStack {
            Group {
                SafetyMapView(selectedSafetyLog: $selectedSafetyLog,
                              drawerViewState: $drawerViewState,
                              isPresentingDetailView: isPresentingSafetyLogDetailView)
                    .environmentObject(safetyViewModel)
                drawerView
            }
            .allowsHitTesting(isPresentingSafetyLogDetailView ? false : true)
            .blur(radius: isPresentingSafetyLogDetailView ? 40 : 0)
            
            if isPresentingSafetyLogDetailView {
                SafetyLogDetailView(selectedSafetyLog: $selectedSafetyLog, drawerViewState: $drawerViewState)
                    .padding()
                    .environmentObject(safetyViewModel)
            }
        }
        .animation(.easeInOut, value: isPresentingSafetyLogDetailView)
        .alertsOverlayView(alert: $safetyViewModel.alert)
    }
    
    private var drawerView: some View {
        BMDrawerView(drawerViewState: $drawerViewState, hPadding: 16) {
            VStack(alignment: .leading) {
                alertsDrawerHeaderView
                
                if safetyViewModel.isLoading {
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
                                .environmentObject(safetyViewModel)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .transition(.scale)
                        .animation(.default, value: safetyViewModel.filteredSafetyLogs)
                    } else {
                        emptySafetyLogsView
                    }
                }
            }
        }
    }
    
    private var drawerContentView: some View {
        VStack(alignment: .leading) {
            alertsDrawerHeaderView
            
            if safetyViewModel.isLoading {
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
                            .environmentObject(safetyViewModel)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .transition(.scale)
                    .animation(.default, value: safetyViewModel.filteredSafetyLogs)
                } else {
                    emptySafetyLogsView
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
                if !safetyViewModel.filteredSafetyLogs.isEmpty {
                    Text("^[\(safetyViewModel.filteredSafetyLogs.count) Result](inflect: true)")
                        .font(Font(BMFont.regular(16)))
                        .foregroundStyle(.gray)
                }
                if #unavailable(iOS 26.0) {
                    Spacer()
                    SafetyLogFilterButton(safetyLogFilterStates: $safetyViewModel.selectedSafetyLogFilterStates, drawerViewState: $drawerViewState)
                        .disabled(safetyViewModel.filteredSafetyLogs.isEmpty)
                        .opacity(safetyViewModel.filteredSafetyLogs.isEmpty ? 0.5 : 1)
                }
            }
            
            if #unavailable(iOS 26.0) {
                if !safetyViewModel.selectedSafetyLogFilterStates.isEmpty {
                    SafetyViewFilterScrollView(drawerViewState: $drawerViewState)
                        .environmentObject(safetyViewModel)
                }
            }
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



#Preview {
    SafetyView()
}
