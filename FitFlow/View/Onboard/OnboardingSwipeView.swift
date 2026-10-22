//
//  OnboardingSwipeView.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct OnboardingSwipeView: View {
    @State private var activeItemID: Int? = 1
    let coordinator: AppCoordinator
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 1,
            title: "onboard_title_1",
            description: "onboard_desc_1",
            icon: "sparkles"
        ),
        OnboardingPage(
            id: 2,
            title: "onboard_title_2",
            description: "onboard_desc_2",
            icon: "chart.line.uptrend.xyaxis"
        ),
        OnboardingPage(
            id: 3,
            title: "onboard_title_3",
            description: "onboard_desc_3",
            icon: "flame.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .id(page.id)
                            .containerRelativeFrame(.horizontal)
                    }
                    .background(Color(.systemBackground))
                    .scrollTargetLayout()
                }
            }
            .disabled(true)
            .scrollPosition(id: $activeItemID)
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
            
            OnboardingFooterView(
                activeItemID: $activeItemID,
                numberOfPages: pages.count,
                pages: pages,
                onPressContinue: {
                    coordinator.replace(page: .Onboarding)
                }
            )
        }
    }
}

#Preview {
    OnboardingSwipeView(coordinator: AppCoordinator())
}

