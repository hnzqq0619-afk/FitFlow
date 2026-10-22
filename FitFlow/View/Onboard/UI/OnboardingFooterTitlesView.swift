//
//  OnboardingFooterTitlesView.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import SwiftUI

struct OnboardingFooterTitlesView: View {
    @Binding var activeItemID: Int?
    var title: String
    var desc: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(title))
                .font(.title2.bold())
                .foregroundColor(.white)
                .id(activeItemID)
                .transition(.opacity.animation(.easeIn(duration: 0.6)))
            
            Text(LocalizedStringKey(desc))
                .id(activeItemID)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .transition(.opacity.animation(.easeIn(duration: 0.6)))
                .frame(maxWidth: 280, alignment: .leading)
                .lineSpacing(4)
        }
    }
}

#Preview {
    OnboardingFooterTitlesView(activeItemID: .constant(3), title: "title", desc: "desc")
}
