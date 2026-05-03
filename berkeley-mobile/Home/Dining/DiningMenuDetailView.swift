//
//  DiningMenuItemDetailView.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 3/13/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//
import SwiftUI

struct DiningMenuItemDetailView: View {

    var menuItem: BMMenuItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let menuDetail = menuItem.recipeDetails {
                    if menuDetail.nutrition != nil && !menuDetail.remainingNutrition.isEmpty {
                        servingSizeSection
                        macronutrientsSection
                        nutritionFactsSection
                    }
                    ingredientsSection
                    allergensSection
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

    @ViewBuilder
    private var servingSizeSection: some View {
        if let menuDetail = menuItem.recipeDetails, let servingSize = menuDetail.servingSize {
            VStack(alignment: .leading, spacing: 8) {
                Text("Serving Size")
                    .font(Font(BMFont.bold(20)))
                DiningDetailRowView {
                    Text(servingSize)
                        .font(Font(BMFont.regular(15)))
                }
            }
        }
    }

    @ViewBuilder
    private var macronutrientsSection: some View {
        if let menuDetail = menuItem.recipeDetails {
            VStack(alignment: .leading, spacing: 8) {
                Text("Macronutrients")
                    .font(Font(BMFont.bold(20)))
                Group {
                    Text("Calories: \(String(format: "%.1f", menuDetail.calories))")
                        .font(Font(BMFont.regular(15)))
                    MacronutrientsCapsuleView(protein: menuDetail.protein, fat: menuDetail.fat, carb: menuDetail.carb)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(BMColor.cardBackground))
                )
            }
        }
    }

    @ViewBuilder
    private var nutritionFactsSection: some View {
        if let menuDetail = menuItem.recipeDetails {
            VStack(alignment: .leading, spacing: 8) {
                Text("Nutrition Facts")
                    .font(Font(BMFont.bold(20)))
                VStack(spacing: 8) {
                    ForEach(menuDetail.remainingNutrition.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
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

    @ViewBuilder
    private var ingredientsSection: some View {
        if let ingredients = menuItem.recipeDetails?.ingredients {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredients")
                    .font(Font(BMFont.bold(20)))
                Text(ingredients)
                    .font(Font(BMFont.regular(15)))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(BMColor.cardBackground))
                    )
            }
        }
    }

    @ViewBuilder
    private var allergensSection: some View {
        if let allergens = menuItem.recipeDetails?.allergens, !allergens.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Allergens")
                    .font(Font(BMFont.bold(20)))
                DiningDetailRowView {
                    Text(allergens.joined(separator: ", "))
                        .font(Font(BMFont.regular(15)))
                }
            }
        }
    }
}

// MARK: - MacronutrientsCapsuleView

struct MacronutrientsCapsuleView: View {
    var protein: Int
    var fat: Int
    var carb: Int

    private let macros: [(label: String, color: Color)] = [
        ("Protein", .green),
        ("Carb", .blue),
        ("Fat", .orange)
    ]

    var body: some View {
        let total = protein + fat + carb
        if total > 0 {
            let segments: [(value: Int, color: Color)] = [
                (protein, .green),
                (carb, .blue),
                (fat, .orange)
            ]
            VStack {
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
                HStack {
                    Spacer()
                    ForEach(macros, id: \.label) { macro in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(macro.color)
                                .frame(width: 12, height: 12)
                            Text(macro.label)
                                .font(Font(BMFont.regular(12)))
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
