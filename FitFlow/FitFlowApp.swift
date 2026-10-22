import SwiftUI

@main
@MainActor
struct FitFlowApp: App {
    init() { setupDependencies() }

    var body: some Scene {
        WindowGroup { ContentView() }
    }

    private func setupDependencies() {
        let container = DependencyContainer.shared
        container.register(PlanRepository.self) { PlanRepository() }
        container.register(GeminiServiceProtocol.self) { GeminiService() }
        container.register(HealthManager.self) { HealthManager() }
        container.register(HealthStoreProtocol.self) { container.resolve(HealthManager.self) }
        container.register(StorageServiceProtocol.self) { StorageManager() }
        container.register(TrackingManager.self) {
            TrackingManager(repository: container.resolve(PlanRepository.self))
        }
        container.register(TrackingServiceProtocol.self) { container.resolve(TrackingManager.self) }
    }
}
