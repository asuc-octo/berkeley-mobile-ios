//
//  DiningDetailView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import SwiftUI
import MapKit

// MARK: - DiningDetailView

struct DiningDetailView: View {
    @Environment(DiningHallsViewModel.self) private var viewModel
    
    var diningHall: BMDiningHall
    
    @State private var selectedTabIndex = 0
    @State private var showAlert = false
    
    private var categoriesAndMenuItems:  [BMMealCategory] {
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
        .padding(.top, 10)
        .onAppear {
            viewModel.logOpenedDiningDetailViewAnalytics(for: diningHall.name)
        }
        .navigationTitle(diningHall.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("\(diningHall.name)'s Hours", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            let hoursText: String = {
                if diningHall.hours.isEmpty {
                    return "No hours available"
                } else {
                    let timeFormatter = DateFormatter()
                    timeFormatter.timeStyle = .short

                    let periods = diningHall.hours.map { interval in
                        let startTime = timeFormatter.string(from: interval.start)
                        let endTime = timeFormatter.string(from: interval.end)
                        return "\(startTime) - \(endTime)"
                    }.joined(separator: "\n")

                    return (periods)
                }
            }()

            Text(hoursText)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    showAlert = true
                }) {
                    Image(systemName: "info.circle")
                }

                if let lat = diningHall.latitude, let lng = diningHall.longitude {
                    Button(action: {
                        let coordinate = CLLocationCoordinate2DMake(lat, lng)
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                        mapItem.name = diningHall.name
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                    }) {
                        Image(systemName: "map")
                    }
                }
                
                if let phoneNumber = diningHall.phoneNumber {
                    Button(action: {
                        guard let url = URL(string: "tel://\(phoneNumber)"),
                            UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
                        HStack {
                            VStack(alignment: .leading) {
                                Text(menuItem.name)
                                    .font(Font(BMFont.regular(15)))
                                DiningMenuItemIconsView(menuItem: menuItem)
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        .padding()
                        .background(Color(BMColor.cardBackground))
                        .clipShape(.capsule)
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
