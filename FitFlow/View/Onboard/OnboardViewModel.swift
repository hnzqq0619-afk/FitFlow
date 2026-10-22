import Foundation
import Combine

@MainActor
final class OnboardViewModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var lastError: String?
    @Published var isLoadingPlan = false
    @Published var isLoadingHealthData = false
    @Published var step = 1

    private let coordinator: AppCoordinator
    private let healthStore: HealthStoreProtocol
    private let geminiService: GeminiServiceProtocol
    private let repository: PlanRepository
    private var generationTask: Task<Void, Never>?

    init(coordinator: AppCoordinator, healthStore: HealthStoreProtocol,
         geminiService: GeminiServiceProtocol, repository: PlanRepository) {
        self.coordinator = coordinator; self.healthStore = healthStore
        self.geminiService = geminiService; self.repository = repository
        profile = repository.archive.profile ?? UserProfile()
    }

    func nextStep() {
        guard !isLoadingPlan, !isLoadingHealthData else { return }
        if step < 3 { step += 1 } else { generatePlan() }
    }

    func importHealthData() async {
        guard !isLoadingHealthData else { return }
        isLoadingHealthData = true
        defer { isLoadingHealthData = false }
        await healthStore.requestAuthorization()
        // Fill only missing values. Never replace a manual edit.
        if profile.height == nil { profile.height = healthStore.height }
        if profile.weight == nil { profile.weight = healthStore.weight }
        if profile.age == nil, let birth = healthStore.birthDate {
            profile.age = Calendar.current.dateComponents([.year], from: birth, to: Date()).year
        }
    }

    func generatePlan() {
        guard !isLoadingPlan else { return }
        isLoadingPlan = true
        lastError = nil
        let snapshot = profile
        generationTask = Task {
            defer { isLoadingPlan = false }
            do {
                let start = Calendar.current.startOfDay(for: Date())
                let prompt = try geminiService.generateWorkoutAndMealPlan(profile: snapshot, startDate: start)
                let response = try await geminiService.fetchWorkoutPlan(prompt: prompt)
                try Task.checkCancellation()
                let plan = try WeeklyPlan(response: response, profile: snapshot, startDate: start)
                try repository.save(plan: plan, profile: snapshot)
                coordinator.replace(page: .Dashboard)
            } catch is CancellationError {
                // Leaving the screen cancels the request and does not complete onboarding.
            } catch {
                if !Task.isCancelled { lastError = error.localizedDescription }
            }
        }
    }

    func saveWithoutAI() {
        do {
            try repository.saveProfile(profile)
            coordinator.replace(page: .Dashboard)
        } catch { lastError = error.localizedDescription }
    }

    func cancelGeneration() { generationTask?.cancel() }
}
