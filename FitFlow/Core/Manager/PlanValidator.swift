import Foundation

enum PlanValidator {
    static func validate(_ response: AIWorkoutResponse, profile: UserProfile,
                         startDate: Date, calendar: Calendar = .current) throws {
        try profile.validate()
        let meals = response.mealPlan.dailyMealPlans
        let workouts = response.dailyPlan
        guard meals.count == 7, workouts.count == 7,
              Set(meals.compactMap(\.dayIndex)) == Set(1...7),
              Set(workouts.compactMap(\.dayIndex)) == Set(1...7) else {
            throw AppError.message("AI 返回的计划不是完整且不重复的七天，请重试。")
        }
        guard !response.weeklyFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !response.nutritionAdvice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.message("AI 返回的计划缺少总结。")
        }
        for day in meals {
            let expected = PlanDates.key(PlanDates.date(dayIndex: day.dayIndex!, start: startDate, calendar: calendar),
                                         calendar: calendar)
            guard day.day == expected, (3...5).contains(day.meals.count) else {
                throw AppError.message("AI 返回的饮食日期或餐次数量不正确。")
            }
            let mainMeals = day.meals.filter { ["早餐", "午餐", "晚餐"].contains($0.mealType) }
            guard Set(mainMeals.map(\.mealType)) == Set(["早餐", "午餐", "晚餐"]),
                  mainMeals.count == 3,
                  mainMeals.filter({ $0.source == "外卖" }).count == profile.takeawayMealsPerDay else {
                throw AppError.message("饮食计划缺少三餐，或外卖次数与资料不符。")
            }
            for meal in day.meals {
                guard ["早餐", "午餐", "晚餐", "加餐"].contains(meal.mealType),
                      ["自制", "外卖"].contains(meal.source ?? ""),
                      !meal.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !meal.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !(meal.portion ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      meal.calories > 0, meal.calories <= 8000,
                      [meal.protein, meal.carbs, meal.fat].allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= 2000 }),
                      meal.videoUrl == nil || VideoLinks.url(meal.videoUrl) != nil,
                      meal.source != "外卖" || !(meal.orderNotes ?? "").isEmpty else {
                    throw AppError.message("AI 返回了不完整的餐食、异常营养值或不可信视频链接。")
                }
                let energy = meal.protein * 4 + meal.carbs * 4 + meal.fat * 9
                guard abs(energy - Double(meal.calories)) / Double(meal.calories) <= 0.25 else {
                    throw AppError.message("AI 餐食的热量与营养素不一致，请重试。")
                }
            }
            let totals = [
                (Double(day.meals.reduce(0) { $0 + $1.calories }), Double(profile.macros.calories)),
                (day.meals.reduce(0.0) { $0 + $1.protein }, Double(profile.macros.protein)),
                (day.meals.reduce(0.0) { $0 + $1.carbs }, Double(profile.macros.carbs)),
                (day.meals.reduce(0.0) { $0 + $1.fat }, Double(profile.macros.fat))
            ]
            guard totals.allSatisfy({ abs($0.0 - $0.1) / $0.1 <= 0.25 }) else {
                throw AppError.message("AI 的每日营养合计偏离你的目标超过 25%，请重试。")
            }
        }
        for day in workouts {
            let expected = PlanDates.key(PlanDates.date(dayIndex: day.dayIndex!, start: startDate, calendar: calendar),
                                         calendar: calendar)
            guard day.day == expected, let rest = day.isRestDay, let minutes = day.durationMinutes,
                  !day.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  (rest ? (day.exercises.isEmpty && minutes == 0)
                        : (!day.exercises.isEmpty && (1...profile.workoutMinutes).contains(minutes))) else {
                throw AppError.message("AI 的训练日期、休息日或训练时长不符合要求。")
            }
            for exercise in day.exercises {
                guard !exercise.name.isEmpty, !exercise.sets.isEmpty, !exercise.reps.isEmpty,
                      exercise.videoUrl == nil || VideoLinks.url(exercise.videoUrl) != nil else {
                    throw AppError.message("AI 返回了不完整动作或不可信视频链接。")
                }
            }
        }
        guard workouts.filter({ $0.isRestDay == false }).count == profile.workoutDaysPerWeek else {
            throw AppError.message("AI 的每周训练天数与你设置的不一致。")
        }
    }
}

enum VideoLinks {
    static func url(_ value: String?) -> URL? {
        guard let value, let parts = URLComponents(string: value),
              parts.scheme?.lowercased() == "https", parts.user == nil, parts.password == nil,
              parts.port == nil, let host = parts.host?.lowercased() else { return nil }
        if host == "youtu.be", parts.path.count > 1 { return parts.url }
        if ["youtube.com", "www.youtube.com", "m.youtube.com"].contains(host),
           parts.path == "/watch",
           parts.queryItems?.contains(where: { $0.name == "v" && !($0.value ?? "").isEmpty }) == true {
            return parts.url
        }
        return nil
    }
}
