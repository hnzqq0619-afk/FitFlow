//
//  Coordinator.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI
import Combine

enum Pages: Identifiable, Hashable {
    case OnboardingSwipe
    case Onboarding
    case Dashboard
    case Detail(aiWorkout: DailyWorkout, nutrition: String)
    case MealPlanDetailView(dailyMealPlan: DailyMealPlan)
    
    var id: String {
        switch self {
        case .OnboardingSwipe: return "OnboardingSwipe"
        case .Onboarding: return "Onboarding"
        case .Dashboard: return "Dashboard"
        case .Detail(let aiWorkout, let nutrition): return "Detail_\(aiWorkout.id.uuidString)_\(nutrition.prefix(20))"
        case .MealPlanDetailView(let meal): return "MealPlanDetailView_\(meal.id.uuidString)"
        }
    }
}

enum Sheet: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case OnboardingPrivacySheet
    case NetworkConnectivitySheet
}

enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case demo
}

@MainActor
class AppCoordinator: ObservableObject {
    @Published var root: Pages = .OnboardingSwipe
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    @Injected(PlanRepository.self) private var repository
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let hasData = repository.archive.profile != nil || repository.archive.legacyPlan != nil || repository.loadError != nil
        if hasData { root = .Dashboard }
        else { root = .OnboardingSwipe }
        
        setupConnectivityMonitoring()
    }
    
    private func setupConnectivityMonitoring() {
        /* connectivityService.connectivityStatus
            .dropFirst() // Skip initial value
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.presentSheet(.NetworkConnectivitySheet)
                }
            }
            .store(in: &cancellables)
         */
    }
    
    func push(page: Pages) {
        path.append(page)
    }
    
    func pop() {
        if !path.isEmpty { path.removeLast() }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ cover: FullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissCover() {
        self.fullScreenCover = nil
    }
    
    func replace(page: Pages) {
        self.root = page
        self.path = NavigationPath()
    }
    
    func refreshRootBasedOnStorage() {
        let value = repository.archive.profile != nil || repository.archive.legacyPlan != nil || repository.loadError != nil
        if value {
            root = .Dashboard
        } else {
            root = .OnboardingSwipe
        }
        path = NavigationPath()
    }
    
    @ViewBuilder
    func build(page: Pages) -> some View {
        switch page {
        case .OnboardingSwipe: OnboardingSwipeView(coordinator: self)
        case .Onboarding: OnboardingView(coordinator: self)
        case .Dashboard: DashboardView(username: "")
        case .Detail(let aiWorkout, let nutrition):
            WorkoutDetailView(aiWorkout: aiWorkout, nutrition: nutrition)
        case .MealPlanDetailView(let meal):
            MealPlanDetailView(dailyMealPlan: meal)
        }
    }
        
    @ViewBuilder
    func buildSheet(sheet: Sheet) -> some View {
        switch sheet {
        default:
            EmptyView()
        }
    }
        
    @ViewBuilder
    func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case .demo: EmptyView()
        }
    }
}
