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
            // TODO: Make into own custom view if future calls
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 35))
                .foregroundStyle(.gray)
        }
    }
}


// MARK: - SafetyLogView

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

#Preview {
    SafetyLogDetailView(isPresentingSafetyLogDetailView: .constant(true), selectedSafetyLog: SafetyViewManager.getSampleSafetyLog())
        .padding()
}
