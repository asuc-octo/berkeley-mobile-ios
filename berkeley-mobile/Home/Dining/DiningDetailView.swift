//
//  DiningDetailView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import SwiftUI

// MARK: - DiningDetailView

struct DiningDetailView: View {
    @Environment(DiningHallsViewModel.self) private var viewModel
    
    var diningHall: BMDiningHall
    
    @State private var selectedTabIndex = 0
    
    private var allDayString: String? {
        return diningHall.meals[BMMeal.BMMealType.allDay]?.categoriesAndMenuItems.first?.menuItems.first?.name
    }
    
    private var categoriesAndMenuItems: [BMMealCategory] {
        switch selectedTabIndex {
        case 0:
            return diningHall.meals[BMMeal.BMMealType.breakfast]?.categoriesAndMenuItems ?? []
        case 1:
            return diningHall.meals[BMMeal.BMMealType.lunch]?.categoriesAndMenuItems ?? []
        default:
            return diningHall.meals[BMMeal.BMMealType.dinner]?.categoriesAndMenuItems ?? []
        }
    }
    
    var body: some View {
        VStack {
            if let allDayString {
                VStack {
                    DiningDetailRowView {
                        Text(allDayString)
                            .font(Font(BMFont.regular(15)))
                    }
                    Spacer()
                }
                .padding()
            } else {
                BMSegmentedControlView(tabNames: ["Breakfast", "Lunch", "Dinner"], selectedTabIndex: $selectedTabIndex)
                if categoriesAndMenuItems.isEmpty {
                    Text("No Menu Items Available")
                        .fontWeight(.semibold)
                        .padding(.top, 25)
                    Spacer()
                } else {
                    List {
                        DiningItemsListView(categoriesAndMenuItems: categoriesAndMenuItems)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.top, 0)
                }
            }
        }
        .padding(.top, 10)
        .onAppear {
            viewModel.logOpenedDiningDetailViewAnalytics(for: diningHall.name)
        }
        .navigationTitle(diningHall.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if diningHall.hasCoordinate {
                    Button(action: {
                        viewModel.openDiningHallInMaps(for: diningHall)
                    }) {
                        Image(systemName: "map")
                    }
                }
                
                if diningHall.hasPhoneNumber {
                    Button(action: {
                        viewModel.callDiningHall(for: diningHall)
                    }) {
                        Image(systemName: "phone")
                    }
                }
            }
        }
    }
}


// MARK: - DiningItemsListView

struct DiningItemsListView: View {
    var categoriesAndMenuItems: [BMMealCategory]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(categoriesAndMenuItems, id: \.categoryName) { mealCategory in
                Section {
                    ForEach(mealCategory.menuItems, id: \.itemId) { menuItem in
                        DiningDetailRowView {
                            Text(menuItem.name)
                                .font(Font(BMFont.regular(15)))
                            DiningMenuItemIconsView(menuItem: menuItem)
                        }
                    }
                } header: {
                    HStack {
                        Text(mealCategory.categoryName)
                            .font(Font(BMFont.bold(20)))
                            .font(.headline)
                        Spacer()
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}


// MARK: - DiningDetailRowView

struct DiningDetailRowView<Content: View>: View {
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                content()
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .background(Color(BMColor.cardBackground))
        .clipShape(.capsule)
    }
}


// MARK: - DiningMenuItemIconsView

struct DiningMenuItemIconsView: View {
    @Environment(\.menuIconCache) private var menuIconCache
    
    var menuItem: BMMenuItem
    
    @State private var menuItemIconImages: [UIImage] = []
    
    var body: some View {
        HStack {
            ForEach(menuItemIconImages, id: \.self) { menuItemIconImage in
                Image(uiImage: menuItemIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        }
        .onAppear {
            Task {
                menuItemIconImages = await menuIconCache.fetchMenuIconImages(for: menuItem.icons.map { $0.iconURL })
            }
        }
    }
}
