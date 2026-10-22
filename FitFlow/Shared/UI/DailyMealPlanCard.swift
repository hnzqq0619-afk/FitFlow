//
//  DailyMealPlanCard.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct DailyMealPlanCard: View {
    let dailyMealPlan: DailyMealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dailyMealPlan.day)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(dailyMealPlan.meals.prefix(3)) { meal in
                    HStack {
                        Image(systemName: mealIcon(for: meal.mealType))
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(meal.name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                if dailyMealPlan.meals.count > 3 {
                    Text(String(format: NSLocalizedString(LocalizableEnum.moreMeals.rawValue, comment: ""), dailyMealPlan.meals.count - 3))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 60, alignment: .topLeading)
            .padding(.bottom, 12)
            
            HStack {
                Image(systemName: "fork.knife")
                Text(String(format: NSLocalizedString(LocalizableEnum.meals.rawValue, comment: ""), dailyMealPlan.meals.count))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func mealIcon(for mealType: String) -> String {
        switch mealType.lowercased() {
        case "kahvaltı", "早餐":
            return "sunrise.fill"
        case "öğle yemeği", "午餐":
            return "sun.max.fill"
        case "akşam yemeği", "晚餐":
            return "moon.fill"
        case "ara öğün", "加餐":
            return "leaf.fill"
        default:
            return "fork.knife"
        }
    }
}

#Preview {
    DailyMealPlanCard(dailyMealPlan: DailyMealPlan(
        day: "Pazartesi",
        meals: [
            Meal(
                mealType: "Kahvaltı",
                name: "Yulaf Ezmesi",
                description: "",
                calories: 350,
                protein: 15.0,
                carbs: 50.0,
                fat: 12.0,
                videoUrl: nil
            ),
            Meal(
                mealType: "Öğle Yemeği",
                name: "Tavuk Salatası",
                description: "",
                calories: 450,
                protein: 35.0,
                carbs: 30.0,
                fat: 20.0,
                videoUrl: nil
            )
        ]
    ))
}

