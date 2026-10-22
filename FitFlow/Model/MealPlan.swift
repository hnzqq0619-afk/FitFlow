import Foundation

struct MealPlan: Codable, Identifiable {
    var id = UUID()
    let startDate: Date
    let timeZoneID: String
    let days: [MealPlanDay]
    let nutritionAdvice: String
}
