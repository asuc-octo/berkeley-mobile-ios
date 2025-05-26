//
//  CalendarSectionView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/26/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CalendarSectionView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    var scrollProxy: ScrollViewProxy
    var tapCompletion: ((Int) -> Void)?
    
    var body: some View {
        VStack {
            calendarDivider
            CalendarView() { day in
                tapCompletion?(day)
            }
            .environmentObject(calendarViewModel)
            calendarDivider
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        .buttonStyle(PlainButtonStyle())
    }
    
    private var calendarDivider: some View {
        Divider()
            .background(Color(BMColor.gradientLightGrey))
    }
}

#Preview {
    let calendarViewModel = CalendarViewModel()
    ScrollViewReader { proxy in
        CalendarSectionView(scrollProxy: proxy)
            .environmentObject(calendarViewModel)
    }
}
