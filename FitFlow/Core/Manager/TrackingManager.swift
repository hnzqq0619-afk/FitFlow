import Foundation
import Combine

@MainActor
protocol TrackingServiceProtocol {
    func toggleCompletion(for workoutID: String, scheduledDate: Date) throws
    func isWorkoutCompleted(id: String, scheduledDate: Date) -> Bool
}

@MainActor
final class TrackingManager: ObservableObject, TrackingServiceProtocol {
    private let repository: PlanRepository
    private var subscription: AnyCancellable?

    init(repository: PlanRepository) {
        self.repository = repository
        subscription = repository.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
    }
    func toggleCompletion(for workoutID: String, scheduledDate: Date) throws {
        try repository.toggleCompletion(id: workoutID, scheduledDate: scheduledDate)
    }
    func isWorkoutCompleted(id: String, scheduledDate: Date) -> Bool {
        repository.isCompleted(id: id, scheduledDate: scheduledDate)
    }
}
