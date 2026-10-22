//
//  AISummaryCard.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct AISummaryCard: View {
    let focus: String
    let nutrition: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI Koç Analizi", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
            }
            
            Text(focus)
                .font(.title3)
                .fontWeight(.bold)
            
            Divider()
            
            Text(nutrition)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    AISummaryCard(focus: "", nutrition: "")
}
