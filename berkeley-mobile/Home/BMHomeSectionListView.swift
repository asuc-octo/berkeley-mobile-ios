//
//  BMHomeSectionListView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 6/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMHomeSectionListView: View {
    var sectionType: HomeDrawerViewType
    var items: [SearchItem & HasLocation & HasImage]
    var mapViewController: MapViewController
    
    var body: some View {
        VStack {
            sectionHeaderView
            
            if #available(iOS 17.0, *) {
                listView
                    .contentMargins(.top, 0)
                    .contentMargins([.leading, .trailing], 5)
            } else {
                listView
            }
        }
        .padding()
        .background(Color(BMColor.cardBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var sectionHeaderView: some View {
        HStack(spacing: 10) {
            Image(systemName: sectionType.getSectionInfo().systemName)
            Text(sectionType.getSectionInfo().title)
            Spacer()
            Text("\(items.count)")
                .font(Font(BMFont.bold(15)))
                .addBadgeStyle(widthAndHeight: 30, isInteractive: false)
        }
        .font(Font(BMFont.bold(20)))
    }
    
    private var listView: some View {
        List(items, id: \.name) { item in
            Button(action: {
                mapViewController.choosePlacemark(item: item)
            }) {
                HomeSectionListRowView(rowItem: item)
                    .frame(width: 290)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color(BMColor.cardBackground))
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    let homeViewModel = HomeViewModel()
    let diningHalls = [
        BMDiningLocation(name: "Cafe 3", address: "2436 Durant Ave, Berkeley, CA 94704", phoneNumber: nil, imageLink: "https://firebasestorage.googleapis.com/v0/b/berkeley-mobile.appspot.com/o/images%2FCafe3.jpg?alt=media&token=f1062476-2cb0-4ce9-9ac1-6109bf588aaa", shifts: MealMap(), hours: nil, latitude: nil, longitude: nil)
    ]
    
    BMHomeSectionListView(sectionType: .dining, items: diningHalls, mapViewController: MapViewController())
}
