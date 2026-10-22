//
//  MacroIndicator.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct MacroIndicator: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value).bold()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    MacroIndicator(label: "", value: "", color: .red)
}
