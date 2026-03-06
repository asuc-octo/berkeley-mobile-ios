//
//  DiningDetailView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import Firebase
import SwiftUI

// MARK: - DiningDetailView

struct DiningDetailView: View {
    @InjectedObservable(\.diningHallsViewModel) private var viewModel

    var diningHall: BMDiningHall
    
    @State private var selectedTabIndex = 0
    
    private var allDayString: String? {
        return diningHall.meals[BMMeal.BMMealType.other]?.categoriesAndMenuItems.first?.menuItems.first?.name
    }
    
    private var categoriesAndMenuItems: [BMMealCategory] {
        let selectedTabMealType = BMMeal.BMMealType(rawValue: filteredTabNames[selectedTabIndex])!
        return diningHall.getCategoriesAndMenuItems(for: selectedTabMealType)
    }
    
    private var filteredTabNames: [String] {
        return BMMeal.BMMealType.regularMealTypes.filter {
            !diningHall.getCategoriesAndMenuItems(for: $0).isEmpty
        }.map {
            $0.rawValue
        }
    }
    
    var body: some View {
        VStack {
            if let allDayString {
                DiningAllDayView(allDayString: allDayString)
            } else {
                BMSegmentedControlView(
                    tabNames: filteredTabNames,
                    selectedTabIndex: $selectedTabIndex
                )
                if categoriesAndMenuItems.isEmpty {
                    Text("No Menu Items Available")
                        .fontWeight(.semibold)
                        .padding(.top, 25)
                    Spacer()
                } else {
                    ScrollView {
                        DiningItemsListView(selectedTabIndex: $selectedTabIndex,
                                            categoriesAndMenuItems: categoriesAndMenuItems,
                                            diningHall: diningHall,
                                            filteredTabNames: filteredTabNames)
                    }
                }
            }
        }
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


// MARK: - DiningAllDayView

struct DiningAllDayView: View {
    let allDayString: String
    
    var body: some View {
        VStack {
            DiningDetailRowView {
                Text(allDayString)
                    .font(Font(BMFont.regular(15)))
            }
            Spacer()
        }
        .padding()
    }
}


// MARK: - DiningItemsListView

struct DiningItemsListView: View {
    @Binding var selectedTabIndex: Int
    var categoriesAndMenuItems: [BMMealCategory]
    var diningHall: BMDiningHall
    var filteredTabNames: [String]

    private var currentMealTime: String? {
        guard selectedTabIndex < filteredTabNames.count else {
            return nil
        }
        let selectedTabMealType = BMMeal.BMMealType(rawValue: filteredTabNames[selectedTabIndex])
        return diningHall.meals[selectedTabMealType ?? .breakfast]?.time
    }

    var body: some View {
        VStack(spacing: 20) {
            if let currentMealTime {
                Text(currentMealTime)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
            }
            ForEach(categoriesAndMenuItems, id: \.categoryName) { mealCategory in
                HStack {
                    Text(mealCategory.categoryName)
                        .font(Font(BMFont.bold(20)))
                    Spacer()
                }
                ForEach(mealCategory.menuItems, id: \.self) { menuItem in
                    NavigationLink(value: menuItem) {
                        DiningDetailRowView {
                            Text(menuItem.name)
                                .font(Font(BMFont.regular(15)))
                            DiningMenuItemIconsView(menuItem: menuItem)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
    @Injected(\.menuItemIconCacheManager) private var menuItemIconCacheManager
    
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
                menuItemIconImages = await menuItemIconCacheManager.fetchMenuIconImages(for: menuItem.icons.map { $0.iconURL })
            }
        }
    }
}

// MARK: - DiningMenuItemDetailView

struct DiningMenuItemDetailView: View {

    var menuItem: BMMenuItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let menuDetail = menuItem.recipeDetails {
                    if let nutrition = menuDetail.nutrition, !nutrition.isEmpty {
                        let calories = Double(nutrition["Calories (kcal)"] ?? "0") ?? 0
                        let remainingNutrition = nutrition.filter { $0.key != "Calories (kcal)" }
                        let protein = Int(nutrition["Protein (g)"]?.filter { $0.isNumber } ?? "0") ?? 0
                        let carb = Int(nutrition["Carbohydrate (g)"]?.filter { $0.isNumber } ?? "0") ?? 0
                        let fat = (Int(nutrition["Total Lipid/Fat (g)"]?.filter { $0.isNumber } ?? "0") ?? 0) + (Int(nutrition["Trans Fat (g)"]?.filter { $0.isNumber } ?? "0") ?? 0)
                        
                        if let servingSize = menuDetail.servingSize {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Serving Size")
                                    .font(Font(BMFont.bold(20)))
                                DiningDetailRowView {
                                    Text(servingSize)
                                        .font(Font(BMFont.regular(15)))
                                }
                            }
                        }
                        
                        if !remainingNutrition.isEmpty {
                            let macros: [(label: String, color: Color)] = [
                                ("Protein", .green),
                                ("Carb", .blue),
                                ("Fat", .orange)
                            ]
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MacroNutrients")
                                    .font(Font(BMFont.bold(20)))
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Calories: \(String(format: "%.1f", calories))")
                                        .font(Font(BMFont.regular(15)))
                                    ProgressCapsule(protein: protein, fat: fat, carb: carb)
                                    HStack {
                                        Spacer()
                                        ForEach(macros, id: \.label) { macro in
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(macro.color)
                                                    .frame(width: 12, height: 12)
                                                Text(macro.label)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .shadowfy()
                            }
                        }


                        if !remainingNutrition.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nutrition Facts")
                                    .font(Font(BMFont.bold(20)))
                                VStack(spacing: 8) {
                                    ForEach(remainingNutrition.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        DiningDetailRowView {
                                            HStack {
                                                Text(key)
                                                    .font(Font(BMFont.regular(15)))
                                                Spacer()
                                                Text(value)
                                                    .font(Font(BMFont.medium(15)))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if let ingredients = menuDetail.ingredients {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(Font(BMFont.bold(20)))
                            Text(ingredients)
                                .font(Font(BMFont.regular(15)))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadowfy()
                    }

                    if let allergens = menuDetail.allergens, !allergens.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allergens")
                                .font(Font(BMFont.bold(20)))
                            DiningDetailRowView {
                                Text(allergens.joined(separator: ", "))
                                    .font(Font(BMFont.regular(15)))
                            }
                        }
                    }
                } else {
                    Text("No Recipe Details")
                        .font(Font(BMFont.regular(15)))
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(menuItem.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressCapsule: View {
    var protein: Int
    var fat: Int
    var carb: Int

    var body: some View {
        let total = protein + fat + carb
        if total > 0 {
            let segments: [(value: Int, color: Color)] = [
                (protein, .green),
                (carb, .blue),
                (fat, .orange)
            ]
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(segments, id: \.color) { segment in
                        Rectangle()
                            .fill(segment.color)
                            .frame(width: geo.size.width * Double(segment.value) / Double(total))
                    }
                }
            }
            .clipShape(Capsule())
            .frame(maxHeight: 70)
        }
    }
}
