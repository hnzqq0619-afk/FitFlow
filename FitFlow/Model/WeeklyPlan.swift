import Foundation

struct WeeklyPlan: Codable, Identifiable {
    var id = UUID()
    let createdAt: Date
    let profileSnapshot: UserProfile
    let mealPlan: MealPlan
    let workoutPlan: WorkoutPlan
    var schemaVersion = 1

    init(response: AIWorkoutResponse, profile: UserProfile, startDate: Date,
         calendar: Calendar = .current, createdAt: Date = Date()) throws {
        try PlanValidator.validate(response, profile: profile, startDate: startDate, calendar: calendar)
        self.createdAt = createdAt
        profileSnapshot = profile
        let start = calendar.startOfDay(for: startDate)
        mealPlan = MealPlan(startDate: start, timeZoneID: calendar.timeZone.identifier,
            days: response.mealPlan.dailyMealPlans.sorted { $0.dayIndex! < $1.dayIndex! }.map {
                MealPlanDay(date: PlanDates.date(dayIndex: $0.dayIndex!, start: start, calendar: calendar),
                            targetMacros: profile.macros, meals: $0.meals)
            }, nutritionAdvice: response.nutritionAdvice)
        workoutPlan = WorkoutPlan(startDate: start, timeZoneID: calendar.timeZone.identifier,
            weeklyFocus: response.weeklyFocus,
            days: response.dailyPlan.sorted { $0.dayIndex! < $1.dayIndex! }.map {
                WorkoutPlanDay(date: PlanDates.date(dayIndex: $0.dayIndex!, start: start, calendar: calendar),
                               title: $0.title, isRestDay: $0.isRestDay!, durationMinutes: $0.durationMinutes!,
                               exercises: $0.exercises)
            })
    }

    // The existing cards receive stable identifiers and concrete dates.
    var displayResponse: AIWorkoutResponse {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: mealPlan.timeZoneID) ?? .current
        return AIWorkoutResponse(weeklyFocus: workoutPlan.weeklyFocus,
            nutritionAdvice: mealPlan.nutritionAdvice,
            mealPlan: AIMealPlanDTO(dailyMealPlans: mealPlan.days.enumerated().map { index, day in
                DailyMealPlan(id: day.id, day: PlanDates.key(day.date, calendar: calendar),
                              meals: day.meals, dayIndex: index + 1)
            }),
            dailyPlan: workoutPlan.days.enumerated().map { index, day in
                DailyWorkout(id: day.id, day: PlanDates.key(day.date, calendar: calendar), title: day.title,
                             exercises: day.exercises, dayIndex: index + 1, isRestDay: day.isRestDay,
                             durationMinutes: day.durationMinutes, scheduledDate: day.date)
            })
    }
}

enum PlanDates {
    static func date(dayIndex: Int, start: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: dayIndex - 1, to: calendar.startOfDay(for: start))!
    }
    static func key(_ date: Date, calendar: Calendar = .current) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = calendar.timeZone
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
