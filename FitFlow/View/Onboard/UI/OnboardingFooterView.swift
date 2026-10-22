//
//  OnboardingFooterView.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import SwiftUI

struct OnboardingFooterView: View {
    @Binding var activeItemID: Int?
    var numberOfPages: Int
    var pages: [OnboardingPage]
    var onPressContinue: () -> Void
    
    var body: some View {
        let isNextButtonVisible = (activeItemID ?? 1) < numberOfPages
        
        VStack {
            Spacer()
            
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [.black, .black.opacity(0.1)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                .frame(height: 220)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 16) {
                                if let activeItem = pages.first(where: { $0.id == activeItemID }) {
                                    OnboardingFooterTitlesView(
                                        activeItemID: $activeItemID,
                                        title: activeItem.title,
                                        desc: activeItem.description
                                    )
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        HStack(alignment: .center) {
                            OnboardingPageIndicator(
                                numberOfPages: numberOfPages,
                                currentPageIndex: (activeItemID ?? 1) - 1
                            )
                            .opacity(isNextButtonVisible ? 1 : 0)
                            .frame(height: 8)
                            Spacer()
                            if isNextButtonVisible {
                                Button(action: {
                                    guard let activeID = activeItemID else { return }
                                    let nextID = activeID + 1
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        activeItemID = nextID
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        
                        if !isNextButtonVisible {
                            Spacer()
                            Button(action: onPressContinue) {
                                Text(localizable: .next)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.primaryBrand)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 220)
            }
            .frame(height: 220)
        }
    }
}

#Preview {
    OnboardingFooterView(
        activeItemID: .constant(3),
        numberOfPages: 3,
        pages: [
            .init(id: 1, title: "asdasdksdfjnlkdfgsmbkljgfs", description: "sflgşbmnsfşglnks", icon: ""),
            .init(id: 2, title: "asdasdksdfjnlkdfgsmbkljgfs", description: "sflgşbmnsfşglnks", icon: ""),
            .init(id: 3, title: "asdasdksdfjnlkdfgsmbkljgfs", description: "sflgşbmnsfşglnks", icon: ""),
            .init(id: 3, title: "asdasdksdfjnlkdfgsmbkljgfs", description: "sflgşbmnsfşglnkssflgşbmnsfşglnkssflgşbmnsfşglnkssflgşbmnsfşglnks", icon: "")
        ],
        onPressContinue: {}
    )
}
