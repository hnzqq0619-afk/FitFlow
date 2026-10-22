import Foundation

struct MealPlanDay: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let targetMacros: MacroGoals
    let meals: [Meal]
    var calories: Int { meals.reduce(0) { $0 + $1.calories } }
}
