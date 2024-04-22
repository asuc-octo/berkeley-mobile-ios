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
    
    var body: some View {
        ZStack {
            Group {
                Map(coordinateRegion: $safetyViewManager.region, showsUserLocation: true, annotationItems: safetyViewManager.safetyLogs) { safetyLog in
                    MapPin(coordinate: safetyLog.coordinate)
                }
                    .edgesIgnoringSafeArea(.all)
                BMDrawerView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Alerts")
                                .bold()
                                .font(.title)
                        }
                        List(safetyViewManager.safetyLogs, id: \.id) { safetyLog in
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
                    }
                }
            }
            .allowsHitTesting(isPresentingSafetyLogDetailView ? false : true)
            .blur(radius: isPresentingSafetyLogDetailView ? 50 : 0)
            
            if isPresentingSafetyLogDetailView {
                SafetyLogDetailView(isPresentingSafetyLogDetailView: $isPresentingSafetyLogDetailView, selectedSafetyLog: selectedSafetyLog!)
                .padding()
                .matchedGeometryEffect(id: selectedSafetyLog!.id, in: safetyLogDetailAnimation)
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
                
                if isPresentingFullScreen {
                    logLocationView
                } else {
                    Button(action: {}) {
                        logLocationView
                            .padding(5)
                            .background(.green.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                        
                }
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

#Preview {
    SafetyLogView(safetyLog: BMSafetyLog(crime: "Aggravated Assault", date: Date(), detail: "On 4/10/24 at approximately 1855 hours, victim was walking north bound on Gayley Road. A blue convertible Pontiac driving south bound Gayley road from Hearst Ave struck the victim with an unknown projectile. The suspect vehicle continued south bound Gayley Road then proceeded east bound Rim Way. The vehicle was occupied by 2 males and 1 female. The rear passenger subject was responsible for the incident.   Case 24-01042  Aggravated assault is an unlawful attack by one person upon another for the purpose of inflicting severe or aggravated bodily injury. This type of assault is usually accompanied by the use of a weapon or by means likely to produce death or great bodily harm.", latitude: 1.0, location: "Gayley Road, South of Hearst Ave", longitude: 1.0), isPresentingFullScreen: false)
}

