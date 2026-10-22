//
//  AIWorkoutSection.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct AIWorkoutSection: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let plan: AIWorkoutResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Başlık
            HStack {
                Text(localizable: .aiPersonalProgram)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
            }
            .padding(.horizontal)
            
            // 1. Özet Kartı
            VStack(alignment: .leading, spacing: 12) {
                Text(plan.weeklyFocus)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal)
            
            // 2. Günlük Yemek Planı Scroll
            VStack(alignment: .leading, spacing: 10) {
                Text(localizable: .dailyMealPlan)
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(plan.mealPlan.dailyMealPlans) { dailyMealPlan in
                            Button(action: { coordinator.push(page: .MealPlanDetailView(dailyMealPlan: dailyMealPlan))}) {
                                DailyMealPlanCard(dailyMealPlan: dailyMealPlan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(localizable: .dailyWorkoutPlan)
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(plan.dailyPlan) { dayPlan in
                            Button(action: {
                                coordinator.push(page: .Detail(aiWorkout: dayPlan, nutrition: plan.nutritionAdvice))
                            }) {
                                AIDailyPlanCard(plan: dayPlan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
            }
        }
    }
}

#Preview {
    AIWorkoutSection(plan: .init(
        weeklyFocus: "",
        nutritionAdvice: "",
        mealPlan: AIMealPlanDTO(dailyMealPlans: []),
        dailyPlan: []
    ))
}
