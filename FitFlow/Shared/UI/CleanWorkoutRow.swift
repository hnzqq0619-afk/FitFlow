import SwiftUI

struct CleanWorkoutRow: View {
    @ObservedObject private var trackingManager = DependencyContainer.shared.resolve(TrackingManager.self)
    @State private var error: String?
    let workout: Workout
    private var date: Date { Calendar.current.startOfDay(for: Date()) }

    var body: some View {
        let completed = trackingManager.isWorkoutCompleted(id: "legacy-\(workout.id)", scheduledDate: date)
        HStack {
            Button {
                do { try trackingManager.toggleCompletion(for: "legacy-\(workout.id)", scheduledDate: date) }
                catch { self.error = error.localizedDescription }
            } label: {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
            }
            VStack(alignment: .leading) {
                Text(workout.title).font(.headline)
                Text("\(workout.duration_min) 分钟 · \(workout.description)").font(.subheadline)
            }
        }
        .alert("未能保存", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("好") { error = nil }
        } message: { Text(error ?? "") }
    }
}
