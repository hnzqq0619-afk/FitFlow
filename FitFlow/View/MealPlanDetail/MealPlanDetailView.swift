//
//  MealPlanDetailView.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct MealPlanDetailView: View {
    let dailyMealPlan: DailyMealPlan
    
    var body: some View {
        List {
            Section(header: Text(String(format: NSLocalizedString(LocalizableEnum.mealPlan.rawValue, comment: ""), dailyMealPlan.day))) {
                ForEach(dailyMealPlan.meals) { meal in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(meal.mealType)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                            
                            Text(meal.name)
                                .font(.headline)
                        }
                        
                        Text(meal.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let portion = meal.portion { Text("份量：\(portion)").font(.subheadline) }
                        if let source = meal.source { Text("用餐方式：\(source)").font(.caption) }
                        if let notes = meal.orderNotes, !notes.isEmpty {
                            Label(notes, systemImage: "takeoutbag.and.cup.and.straw")
                                .font(.subheadline)
                        }
                        Text("营养为 AI 估算，请结合实际份量核对。")
                            .font(.caption).foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], alignment: .leading, spacing: 12) {
                            MacroInfo(label: NSLocalizedString(LocalizableEnum.calories.rawValue, comment: ""), value: "\(meal.calories)", unit: "kcal", color: .red)
                            MacroInfo(label: NSLocalizedString(LocalizableEnum.protein.rawValue, comment: ""), value: String(format: "%.0f", meal.protein), unit: "g", color: .blue)
                            MacroInfo(label: NSLocalizedString(LocalizableEnum.carbs.rawValue, comment: ""), value: String(format: "%.0f", meal.carbs), unit: "g", color: .orange)
                            MacroInfo(label: NSLocalizedString(LocalizableEnum.fat.rawValue, comment: ""), value: String(format: "%.0f", meal.fat), unit: "g", color: .purple)
                        }
                        .padding(.top, 4)
                        
                        if let url = VideoLinks.url(meal.videoUrl) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.red)
                                    Text(localizable: .watchPreparationVideo)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text(localizable: .total)) {
                let totalCalories = dailyMealPlan.meals.reduce(0) { $0 + $1.calories }
                let totalProtein = dailyMealPlan.meals.reduce(0.0) { $0 + $1.protein }
                let totalCarbs = dailyMealPlan.meals.reduce(0.0) { $0 + $1.carbs }
                let totalFat = dailyMealPlan.meals.reduce(0.0) { $0 + $1.fat }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], alignment: .leading, spacing: 12) {
                    MacroInfo(label: NSLocalizedString(LocalizableEnum.totalCalories.rawValue, comment: ""), value: "\(totalCalories)", unit: "kcal", color: .red)
                    MacroInfo(label: NSLocalizedString(LocalizableEnum.totalProtein.rawValue, comment: ""), value: String(format: "%.0f", totalProtein), unit: "g", color: .blue)
                    MacroInfo(label: NSLocalizedString(LocalizableEnum.totalCarbs.rawValue, comment: ""), value: String(format: "%.0f", totalCarbs), unit: "g", color: .orange)
                    MacroInfo(label: NSLocalizedString(LocalizableEnum.totalFat.rawValue, comment: ""), value: String(format: "%.0f", totalFat), unit: "g", color: .purple)
                }
            }
        }
        .navigationTitle(dailyMealPlan.day)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MacroInfo: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        MealPlanDetailView(dailyMealPlan: DailyMealPlan(
            day: "Pazartesi",
            meals: [
                Meal(
                    mealType: "Kahvaltı",
                    name: "Yulaf Ezmesi",
                    description: "Yulaf ezmesi, muz ve fındık ile hazırlanmış sağlıklı bir kahvaltı",
                    calories: 350,
                    protein: 15.0,
                    carbs: 50.0,
                    fat: 12.0,
                    videoUrl: nil
                )
            ]
        ))
    }
}

