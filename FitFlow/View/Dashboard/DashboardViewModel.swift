import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoadingPlan = false
    @Published var lastError: String?
    private let repository: PlanRepository
    private let geminiService: GeminiServiceProtocol
    private var subscription: AnyCancellable?
    private var generationTask: Task<Void, Never>?

    init(repository: PlanRepository, geminiService: GeminiServiceProtocol) {
        self.repository = repository; self.geminiService = geminiService
        subscription = repository.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
    }

    var profile: UserProfile? { repository.archive.profile }
    var displayName: String {
        let name = profile?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "我" : name
    }
    var workoutPlan: AIWorkoutResponse? { repository.currentPlan?.displayResponse ?? repository.archive.legacyPlan }
    var currentPlan: WeeklyPlan? { repository.currentPlan }
    var plans: [WeeklyPlan] { repository.archive.plans.sorted { $0.createdAt > $1.createdAt } }

    func generate(startDate: Date) {
        guard !isLoadingPlan else { return }
        guard var snapshot = profile else {
            lastError = "请先填写并保存个人资料。"
            return
        }
        if let latest = repository.archive.weights.filter({ $0.measuredAt <= Date() })
            .max(by: { $0.measuredAt < $1.measuredAt }) {
            snapshot.weight = latest.weightKg
        }
        isLoadingPlan = true
        lastError = nil
        generationTask = Task {
            defer { isLoadingPlan = false }
            do {
                let prompt = try geminiService.generateWorkoutAndMealPlan(profile: snapshot, startDate: startDate)
                let response = try await geminiService.fetchWorkoutPlan(prompt: prompt)
                try Task.checkCancellation()
                let plan = try WeeklyPlan(response: response, profile: snapshot, startDate: startDate)
                // Keep the edited profile and baseline separate from a generation-time weight snapshot.
                try repository.save(plan: plan, profile: profile ?? snapshot)
            } catch is CancellationError {
            } catch {
                if !Task.isCancelled { lastError = error.localizedDescription }
            }
        }
    }

    func selectPlan(_ id: UUID) {
        do { try repository.selectPlan(id) } catch { lastError = error.localizedDescription }
    }
    func cancelGeneration() { generationTask?.cancel() }
}
