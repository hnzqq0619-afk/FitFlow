import Foundation

struct WorkoutPlan: Codable, Identifiable {
    var id = UUID()
    let startDate: Date
    let timeZoneID: String
    let weeklyFocus: String
    let days: [WorkoutPlanDay]
}
