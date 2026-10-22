//
//  OnboardingPageIndicator.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import SwiftUI

struct OnboardingPageIndicator: View {
    var numberOfPages: Int
    var currentPageIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPageIndex ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentPageIndex)
            }
        }
    }
}

#Preview {
    OnboardingPageIndicator(numberOfPages: 3, currentPageIndex: 1)
}
