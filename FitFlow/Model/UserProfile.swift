import Foundation

enum FitnessGoal: String, Codable, CaseIterable, Hashable {
    case looseWeight, buildMuscle, condition
    var title: String {
        switch self {
        case .looseWeight: return "减脂"
        case .buildMuscle: return "增肌"
        case .condition: return "改善体能"
        }
    }
}

struct UserProfile: Codable, Equatable {
    var name = ""
    var goal: FitnessGoal = .looseWeight
    var height: Double?
    var weight: Double?
    var age: Int?
    var targetWeight: Double?
    var macros = MacroGoals()
    var foodPreferences = "家常中餐"
    var allergies = ""
    var dailyBudget: Double?
    var takeawayMealsPerDay = 1
    var workoutDaysPerWeek = 3
    var workoutMinutes = 30
    var equipment = "徒手，无器械"
    var dailyStepGoal = 8000
    var allowsAIUpload = false

    enum CodingKeys: String, CodingKey {
        case name, goal, height, weight, age, targetWeight, macros
        case foodPreferences, allergies, dailyBudget, takeawayMealsPerDay
        case workoutDaysPerWeek, workoutMinutes, equipment, dailyStepGoal, allowsAIUpload
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        let oldGoal = try c.decodeIfPresent(String.self, forKey: .goal)
        goal = FitnessGoal(rawValue: oldGoal ?? "") ?? .looseWeight
        height = try c.decodeIfPresent(Double.self, forKey: .height)
        weight = try c.decodeIfPresent(Double.self, forKey: .weight)
        age = try c.decodeIfPresent(Int.self, forKey: .age)
        targetWeight = try c.decodeIfPresent(Double.self, forKey: .targetWeight)
        macros = try c.decodeIfPresent(MacroGoals.self, forKey: .macros) ?? MacroGoals()
        foodPreferences = try c.decodeIfPresent(String.self, forKey: .foodPreferences) ?? foodPreferences
        allergies = try c.decodeIfPresent(String.self, forKey: .allergies) ?? ""
        dailyBudget = try c.decodeIfPresent(Double.self, forKey: .dailyBudget)
        takeawayMealsPerDay = try c.decodeIfPresent(Int.self, forKey: .takeawayMealsPerDay) ?? 1
        workoutDaysPerWeek = try c.decodeIfPresent(Int.self, forKey: .workoutDaysPerWeek) ?? 3
        workoutMinutes = try c.decodeIfPresent(Int.self, forKey: .workoutMinutes) ?? 30
        equipment = try c.decodeIfPresent(String.self, forKey: .equipment) ?? equipment
        dailyStepGoal = try c.decodeIfPresent(Int.self, forKey: .dailyStepGoal) ?? 8000
        allowsAIUpload = try c.decodeIfPresent(Bool.self, forKey: .allowsAIUpload) ?? false
    }

    func validate() throws {
        guard let height, height.isFinite, (50...250).contains(height),
              let weight, weight.isFinite, (20...500).contains(weight),
              let age, (18...100).contains(age) else {
            throw AppError.message("请填写有效的身高、体重和年龄。本版本仅面向成年人。")
        }
        if let targetWeight {
            guard targetWeight.isFinite, (20...500).contains(targetWeight),
                  goal != .looseWeight || targetWeight < weight else {
                throw AppError.message("请填写有效目标体重；减脂目标应低于当前体重。")
            }
        }
        guard (1...7).contains(workoutDaysPerWeek), (10...180).contains(workoutMinutes),
              (0...3).contains(takeawayMealsPerDay), (1...100000).contains(dailyStepGoal),
              [name, foodPreferences, allergies, equipment].allSatisfy({ $0.count <= 500 }) else {
            throw AppError.message("请检查运动、步数、外卖次数和偏好输入。")
        }
        if let dailyBudget {
            guard dailyBudget.isFinite, dailyBudget > 0, dailyBudget <= 10000 else {
                throw AppError.message("每日预算应大于 0，且不超过 10000 元。")
            }
        }
        try macros.validate()
    }
}

enum AppError: LocalizedError {
    case message(String)
    var errorDescription: String? {
        switch self { case .message(let text): return text }
    }
}
