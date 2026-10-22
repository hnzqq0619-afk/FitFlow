import Foundation

// API transport models also read the original SavedWorkoutPlan.
struct AIMealPlanDTO: Codable {
    let dailyMealPlans: [DailyMealPlan]
    enum CodingKeys: String, CodingKey { case dailyMealPlans = "daily_meal_plans" }
}

struct DailyMealPlan: Codable, Identifiable, Hashable {
    var id = UUID()
    let day: String
    let meals: [Meal]
    var dayIndex: Int?
    enum CodingKeys: String, CodingKey { case id, day, meals; case dayIndex = "day_index" }

    init(id: UUID = UUID(), day: String, meals: [Meal], dayIndex: Int? = nil) {
        self.id = id; self.day = day; self.meals = meals; self.dayIndex = dayIndex
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        day = try c.decode(String.self, forKey: .day)
        meals = try c.decode([Meal].self, forKey: .meals)
        dayIndex = try c.decodeIfPresent(Int.self, forKey: .dayIndex)
    }
}

struct Meal: Codable, Identifiable, Hashable {
    var id = UUID()
    let mealType: String
    let name: String
    let description: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let videoUrl: String?
    var portion: String?
    var source: String?
    var orderNotes: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, calories, protein, carbs, fat, portion, source
        case mealType = "meal_type", videoUrl = "video_url", orderNotes = "order_notes"
    }
    init(id: UUID = UUID(), mealType: String, name: String, description: String,
         calories: Int, protein: Double, carbs: Double, fat: Double, videoUrl: String?,
         portion: String? = nil, source: String? = nil, orderNotes: String? = nil) {
        self.id = id; self.mealType = mealType; self.name = name; self.description = description
        self.calories = calories; self.protein = protein; self.carbs = carbs; self.fat = fat
        self.videoUrl = videoUrl; self.portion = portion; self.source = source; self.orderNotes = orderNotes
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        mealType = try c.decode(String.self, forKey: .mealType)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decode(String.self, forKey: .description)
        calories = try c.decode(Int.self, forKey: .calories)
        protein = try c.decode(Double.self, forKey: .protein)
        carbs = try c.decode(Double.self, forKey: .carbs)
        fat = try c.decode(Double.self, forKey: .fat)
        videoUrl = try c.decodeIfPresent(String.self, forKey: .videoUrl)
        portion = try c.decodeIfPresent(String.self, forKey: .portion)
        source = try c.decodeIfPresent(String.self, forKey: .source)
        orderNotes = try c.decodeIfPresent(String.self, forKey: .orderNotes)
    }
}

struct AIWorkoutResponse: Codable {
    let weeklyFocus: String
    let nutritionAdvice: String
    let mealPlan: AIMealPlanDTO
    let dailyPlan: [DailyWorkout]
    enum CodingKeys: String, CodingKey {
        case weeklyFocus = "weekly_focus", nutritionAdvice = "nutrition_advice"
        case mealPlan = "meal_plan", dailyPlan = "daily_plan"
    }
}
