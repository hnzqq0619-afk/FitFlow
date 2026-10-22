//
//  OnboardingPage.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let title: String
    let description: String
    let icon: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(.primaryBrand)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
        .padding(.bottom, 200)
        .background(Color(.systemBackground))
    }
}

#Preview {
    OnboardingPageView(page: .init(id: 1, title: "title", description: "description", icon: ""))
}
