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
    @State private var selectedSafetyLogFilterStates: [BMSafetyLogFilterState]? = [BMSafetyLogFilterState]()
    
    var body: some View {
        ZStack {
            Group {
                Map(coordinateRegion: $safetyViewManager.region, showsUserLocation: true, annotationItems: safetyViewManager.safetyLogs) { safetyLog in
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
        BMDrawerView {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        Text("Alerts")
                            .bold()
                            .font(.title)
                        Spacer()
                        SafetyLogFilterButton(safetyLogFilterStates: $selectedSafetyLogFilterStates)
                    }
                    
                    //Selected Filter Types Section
                    if let safetyLogFilterStates = selectedSafetyLogFilterStates, !safetyLogFilterStates.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(safetyLogFilterStates, id: \.id) { filterState in
                                    HStack {
                                        Text(filterState.rawValue.capitalized)
                                            .foregroundStyle(.white)
                                        Button(action: {
                                            withAnimation {
                                                //Remove filter state
                                                if let removeIndex = selectedSafetyLogFilterStates?.firstIndex(of: filterState) {
                                                    selectedSafetyLogFilterStates?.remove(at: removeIndex)
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
                
                if !safetyViewManager.filteredSafetyLogs.isEmpty {
                    List(safetyViewManager.filteredSafetyLogs, id: \.id) { safetyLog in
                        SafetyLogView(safetyLog: safetyLog, isPresentingFullScreen: false)
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
                    //Show Empty View
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
        }
        .onChange(of: selectedSafetyLogFilterStates) { newValue in
            //Filter safety logs based on new filter states
            guard let selectedSafetyLogFilterStates = selectedSafetyLogFilterStates else { return }
            guard !selectedSafetyLogFilterStates.isEmpty else {
                safetyViewManager.filteredSafetyLogs = safetyViewManager.safetyLogs
                return
            }
            
            var filteredSafetyLogs = [BMSafetyLog]()
            
            let currentDate = Date()
            let timeFilterStates = selectedSafetyLogFilterStates.filter { BMSafetyLogFilterState.timeFilterStates.contains($0) }
            let crimeTypeFilterStates = Array(Set(selectedSafetyLogFilterStates).subtracting(Set(timeFilterStates)))
            
            if !timeFilterStates.isEmpty {
                for selectedTimeFilterState in timeFilterStates {
                    switch selectedTimeFilterState {
                    case .thisMonth:
                        let thisMonthLogs = safetyViewManager.safetyLogs.filter{Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .month)}
                        print(thisMonthLogs)
                        filteredSafetyLogs.append(contentsOf: thisMonthLogs)
                    case .thisWeek:
                        let thisWeekLogs = safetyViewManager.safetyLogs.filter{Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .weekOfYear)}
                        filteredSafetyLogs.append(contentsOf: thisWeekLogs)
                    case .thisYear:
                        let thisYearLogs = safetyViewManager.safetyLogs.filter{Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .year)}
                        filteredSafetyLogs.append(contentsOf: thisYearLogs)
                    case .today:
                        filteredSafetyLogs = filteredSafetyLogs.filter {Calendar.current.isDateInToday($0.date)}
                    default:
                        break
                    }
                }
            } else {
                filteredSafetyLogs = safetyViewManager.safetyLogs
            }
            
            for crimeFilterState in crimeTypeFilterStates {
                filteredSafetyLogs = filteredSafetyLogs.filter { $0.getSafetyLogState == crimeFilterState}
            }
            
            withAnimation {
                safetyViewManager.filteredSafetyLogs = filteredSafetyLogs
            }
        }
    }
}

//MARK: - SafetyLogDetailView
struct SafetyLogDetailView: View {
    @Binding var isPresentingSafetyLogDetailView: Bool
    var selectedSafetyLog: BMSafetyLog
    
    var body: some View {
        VStack {
            HStack {
                closeButton
                Spacer()
            }
            Spacer()
            
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: selectedSafetyLog.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), annotationItems: [selectedSafetyLog]) { safetyLog in
                MapPin(coordinate: safetyLog.coordinate)
            }
            .allowsHitTesting(false)
            .frame(height: 250)
            .frame(minWidth: 300, maxWidth: 500)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .gray.opacity(0.5), radius: 7)
            
            
            Spacer()
            SafetyLogView(safetyLog: selectedSafetyLog, isPresentingFullScreen: true)
            Spacer()
        }
    }
    
    private var closeButton: some View {
        Button(action: {
            withAnimation {
                isPresentingSafetyLogDetailView.toggle()
            }
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.gray)
        }
    }
}

//MARK: - SafetyLogView
struct SafetyLogView: View {
    var safetyLog: BMSafetyLog
    var isPresentingFullScreen: Bool
    
    var body: some View {
        if isPresentingFullScreen {
            mainBody
        } else {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.6), lineWidth: 1)
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
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    private var logTitle: some View {
        HStack {
            Text(safetyLog.crime.capitalized)
                .bold()
                .font(.title2)
            Spacer()
        }
    }
    
    //TODO: - Add "Yesterday" and "Today" verbage
    private var logDateAndTime: some View {
        Text(safetyLog.date.formatted(date: .abbreviated, time: .shortened))
            .font(.subheadline)
    }
    
    private var logLocationView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text(safetyLog.location.capitalized)
                .font(.caption)
                .bold()
        }
        .foregroundStyle(.green)
        
    }
}

//MARK: - SafetyLogFilterButton
struct SafetyLogFilterButton: View {
    @Binding var safetyLogFilterStates: [BMSafetyLogFilterState]?
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
                            .fontWeight(.bold)
                        Image(systemName: "chevron.down")
                    }
                    .foregroundStyle(.white)
                )
        }
        .menuOrder(.fixed)
    }
    
    private func addToSafetyLogFilterStates(for newFilterState: BMSafetyLogFilterState) {
        guard let safetyLogFilterStates = safetyLogFilterStates else { return }
        
        if !safetyLogFilterStates.contains(newFilterState) {
            withAnimation {
                self.safetyLogFilterStates?.append(newFilterState)
            }
        }
    }
}

#Preview {
    SafetyLogView(safetyLog: BMSafetyLog(crime: "Aggravated Assault", date: Date(), detail: "On 4/10/24 at approximately 1855 hours, victim was walking north bound on Gayley Road. A blue convertible Pontiac driving south bound Gayley road from Hearst Ave struck the victim with an unknown projectile. The suspect vehicle continued south bound Gayley Road then proceeded east bound Rim Way. The vehicle was occupied by 2 males and 1 female. The rear passenger subject was responsible for the incident.   Case 24-01042  Aggravated assault is an unlawful attack by one person upon another for the purpose of inflicting severe or aggravated bodily injury. This type of assault is usually accompanied by the use of a weapon or by means likely to produce death or great bodily harm.", latitude: 1.0, location: "Gayley Road, South of Hearst Ave", longitude: 1.0), isPresentingFullScreen: false)
}

