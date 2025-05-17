//
//  BMSafetyMapMarker.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/16/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

@available(iOS 17.0, *)
struct BMSafetyMapMarker: MapContent {
    @EnvironmentObject var safetyViewModel: SafetyViewModel
    
    var safetyLog: BMSafetyLog
    
    var body: some MapContent {
        let dateText = "\(safetyLog.date.formatted(date: .numeric, time: .shortened))"
        let monogramText = "\(safetyLog.getSafetyLogState.rawValue.first!.uppercased())"
        Marker(dateText, monogram: Text(monogramText), coordinate: safetyLog.coordinate)
            .tint(safetyViewModel.crimeInfos[safetyLog.getSafetyLogState]?.color ?? .red)
            .tag(safetyLog)
    }
}
