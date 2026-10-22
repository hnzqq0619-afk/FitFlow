import Foundation

struct WorkoutPlanDay: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let title: String
    let isRestDay: Bool
    let durationMinutes: Int
    let exercises: [Exercise]
}
