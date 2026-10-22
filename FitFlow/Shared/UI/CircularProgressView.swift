//
//  CircularProgressView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().stroke(Color(.systemGray4), lineWidth: 8)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .opacity(0.6)
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(Color.primaryBrand, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 90, height: 90)
    }
}

#Preview {
    CircularProgressView(progress: 12.0)
}
