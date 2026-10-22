//
//  AIDailyPlanCard.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct AIDailyPlanCard: View {
    let plan: DailyWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(plan.day)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.2))
                .foregroundColor(.purple)
                .cornerRadius(8)
            
            Text(plan.title)
                .font(.headline)
                .lineLimit(2)
                .frame(height: 45, alignment: .topLeading)

            if plan.isRestDay == true {
                Text("休息日").font(.caption).foregroundStyle(.secondary)
            } else if let minutes = plan.durationMinutes {
                Text("预计 \(minutes) 分钟").font(.caption).foregroundStyle(.secondary)
            }
            
            HStack {
                Image(systemName: "figure.run")
                Text(String(format: NSLocalizedString("%lld Egzersiz", comment: ""), plan.exercises.count))
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
}

#Preview {
    AIDailyPlanCard(plan: .init(day: "", title: "", exercises: []))
}
