//
//  BMHomeSectionListView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 6/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMHomeSectionListView<Content: View>: View {
    @Environment(HomeDrawerPinViewModel.self) private var homeDrawerPinViewModel
    
    var sectionType: HomeDrawerViewType
    var items: [any HomeDrawerSectionRowItemType]
    var mapViewController: MapViewController
    
    var selectionHandler: ((any HomeDrawerSectionRowItemType) -> Void)?
    @ViewBuilder var swipeActionsContent: ((any HomeDrawerSectionRowItemType) -> Content)
    
    private var sortedItems: [any HomeDrawerSectionRowItemType] {
        let pinned = items.filter { homeDrawerPinViewModel.pinnedRowItemIDSet.contains($0.docID) }
        let nonPinned = items.filter { !homeDrawerPinViewModel.pinnedRowItemIDSet.contains($0.docID) }
        return pinned + nonPinned
    }
    
    var body: some View {
        if items.isEmpty {
            Text("No Available Items")
                .font(Font(BMFont.bold(20)))
                .foregroundStyle(.gray)
            Spacer()
        }
        else {
            VStack {
                if #unavailable(iOS 26.0) {
                    sectionHeaderView
                }
                
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
    
    @ViewBuilder
    private var listView: some View {
        if #available(iOS 26.0, *) {
                List {
                    Section {
                        ForEach(sortedItems, id: \.docID) { item in
                            Button(action: {
                                mapViewController.choosePlacemark(item: item)
                                selectionHandler?(item)
                            }) {
                                HomeSectionListRowView(rowItem: item)
                                    .frame(width: 290)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(BMColor.cardBackground))
                            .swipeActions(allowsFullSwipe: true) {
                               swipeActionsContent(item)
                            }
                        }
                    } header: {
                        sectionHeaderView
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
         else {
            List(sortedItems, id: \.docID) { item in
                Button(action: {
                    mapViewController.choosePlacemark(item: item)
                    selectionHandler?(item)
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
}

#Preview {
    let homeViewModel = HomeViewModel()
    let diningHalls = [
        BMDiningHall(name: "Cafe 3", address: "2436 Durant Ave, Berkeley, CA 94704", phoneNumber: nil, imageLink: "https://firebasestorage.googleapis.com/v0/b/berkeley-mobile.appspot.com/o/images%2FCafe3.jpg?alt=media&token=f1062476-2cb0-4ce9-9ac1-6109bf588aaa", hours: [], latitude: nil, longitude: nil)
    ]
    
    BMHomeSectionListView(sectionType: .dining, items: diningHalls, mapViewController: MapViewController()) {_ in }
}

