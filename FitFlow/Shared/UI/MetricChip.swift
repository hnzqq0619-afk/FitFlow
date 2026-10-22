//
//  MetricChip.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

enum Unit: String, CaseIterable {
    case dk = "分钟"
    case kcal = "kcal"
    case empty = ""
}

struct MetricChip: View {
    let iconName: String
    let value: String
    let unit: Unit
    let label: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: iconName).font(.title2).foregroundColor(color)
            HStack(alignment: .lastTextBaseline,spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                
                if unit != .empty {
                    Text(unit.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(label).font(.caption).foregroundColor(.secondary)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
