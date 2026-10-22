import XCTest
@testable import FitFlowCore

enum Fixtures {
    static var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return c
    }
    static var start: Date { calendar.date(from: DateComponents(year: 2026, month: 10, day: 22))! }
    static var profile: UserProfile {
        var p = UserProfile()
        p.name = "PRIVATE_NAME_DO_NOT_UPLOAD"; p.height = 175; p.weight = 90; p.age = 30
        p.targetWeight = 80; p.macros = MacroGoals(calories: 1800, protein: 120, fat: 60, carbs: 195)
        p.allowsAIUpload = true
        return p
    }
    static var data: Data {
        get throws {
            try Data(contentsOf: Bundle.module.url(forResource: "valid-plan", withExtension: "json", subdirectory: "Fixtures")!)
        }
    }
    static func response(_ mutate: ((inout [String: Any]) -> Void)? = nil) throws -> AIWorkoutResponse {
        var json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        mutate?(&json)
        return try JSONDecoder().decode(AIWorkoutResponse.self, from: JSONSerialization.data(withJSONObject: json))
    }
    static func plan() throws -> WeeklyPlan {
        try WeeklyPlan(response: response(), profile: profile, startDate: start, calendar: calendar, createdAt: start)
    }
}

final class PlanTests: XCTestCase {
    func testStableIDsSurviveSavingAndDisplayAdaptation() throws {
        let plan = try Fixtures.plan()
        let restored = try JSONDecoder().decode(WeeklyPlan.self, from: JSONEncoder().encode(plan))
        XCTAssertEqual(plan.id, restored.id)
        XCTAssertEqual(plan.displayResponse.dailyPlan.map(\.id), restored.displayResponse.dailyPlan.map(\.id))
        XCTAssertEqual(plan.displayResponse.mealPlan.dailyMealPlans.map(\.id),
                       restored.displayResponse.mealPlan.dailyMealPlans.map(\.id))
        XCTAssertEqual(plan.mealPlan.days[0].meals[0].id, restored.mealPlan.days[0].meals[0].id)
        XCTAssertEqual(plan.workoutPlan.days[0].exercises[0].id, restored.workoutPlan.days[0].exercises[0].id)
    }

    func testShuffledDaysAreMappedByIndex() throws {
        let response = try Fixtures.response { json in
            json["daily_plan"] = Array((json["daily_plan"] as! [[String: Any]]).reversed())
            var mealPlan = json["meal_plan"] as! [String: Any]
            mealPlan["daily_meal_plans"] = Array((mealPlan["daily_meal_plans"] as! [[String: Any]]).reversed())
            json["meal_plan"] = mealPlan
        }
        let plan = try WeeklyPlan(response: response, profile: Fixtures.profile,
                                  startDate: Fixtures.start, calendar: Fixtures.calendar)
        XCTAssertEqual(plan.mealPlan.days[0].date, Fixtures.start)
        XCTAssertEqual(plan.displayResponse.dailyPlan[0].day, "2026-10-22")
        XCTAssertEqual(plan.displayResponse.dailyPlan[6].day, "2026-10-28")
    }

    func testMissingAndDuplicateDaysAreRejected() throws {
        let missing = try Fixtures.response { json in
            json["daily_plan"] = Array((json["daily_plan"] as! [[String: Any]]).dropLast())
        }
        XCTAssertThrowsError(try WeeklyPlan(response: missing, profile: Fixtures.profile,
                                            startDate: Fixtures.start, calendar: Fixtures.calendar))
        let duplicate = try Fixtures.response { json in
            var days = json["daily_plan"] as! [[String: Any]]
            days[6]["day_index"] = 1
            json["daily_plan"] = days
        }
        XCTAssertThrowsError(try WeeklyPlan(response: duplicate, profile: Fixtures.profile,
                                            startDate: Fixtures.start, calendar: Fixtures.calendar))
    }

    func testWrongDateAndNutritionAreRejected() throws {
        let wrongDate = try Fixtures.response { json in
            var days = json["daily_plan"] as! [[String: Any]]
            days[0]["day"] = "星期四"
            json["daily_plan"] = days
        }
        XCTAssertThrowsError(try WeeklyPlan(response: wrongDate, profile: Fixtures.profile,
                                            startDate: Fixtures.start, calendar: Fixtures.calendar))
        let wrongNutrition = try Fixtures.response { json in
            var plan = json["meal_plan"] as! [String: Any]
            var days = plan["daily_meal_plans"] as! [[String: Any]]
            var meals = days[0]["meals"] as! [[String: Any]]
            meals[0]["calories"] = -1; days[0]["meals"] = meals
            plan["daily_meal_plans"] = days; json["meal_plan"] = plan
        }
        XCTAssertThrowsError(try WeeklyPlan(response: wrongNutrition, profile: Fixtures.profile,
                                            startDate: Fixtures.start, calendar: Fixtures.calendar))
    }

    func testUnsafeVideoLinksAreRejected() {
        XCTAssertNil(VideoLinks.url("https://youtube.com.evil.example/watch?v=abc"))
        XCTAssertNil(VideoLinks.url("javascript:alert(1)"))
        XCTAssertNil(VideoLinks.url("https://youtube.com@evil.example/watch?v=abc"))
        XCTAssertNotNil(VideoLinks.url("https://www.youtube.com/watch?v=abc"))
    }

    func testLegacyProfileDefaultsDoNotGrantAIConsent() throws {
        let data = Data(#"{"name":"legacy","goal":"weight","height":175,"weight":90,"age":30,"macros":{"calories":1800,"protein":120,"fat":60,"carbs":195}}"#.utf8)
        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
        XCTAssertEqual(profile.goal, .looseWeight)
        XCTAssertFalse(profile.allowsAIUpload)
        XCTAssertEqual(profile.workoutDaysPerWeek, 3)
    }

    func testInvalidProfileAndZeroTargetsAreRejected() {
        XCTAssertThrowsError(try UserProfile().validate())
        var p = Fixtures.profile
        p.height = 0
        XCTAssertThrowsError(try p.validate())
        p = Fixtures.profile; p.macros = MacroGoals()
        XCTAssertThrowsError(try p.validate())
    }

    func testCalendarDaysAcrossDaylightSavingTime() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 30))!
        XCTAssertEqual(PlanDates.key(PlanDates.date(dayIndex: 7, start: start, calendar: calendar), calendar: calendar),
                       "2026-11-05")
    }

    func testProgressAveragesRecordedDaysAndIgnoresFuture() {
        let calendar = Fixtures.calendar
        let day6 = PlanDates.date(dayIndex: 7, start: Fixtures.start, calendar: calendar)
        let now = day6.addingTimeInterval(3600)
        let entries = [
            WeightEntry(measuredAt: Fixtures.start.addingTimeInterval(-86400), weightKg: 100),
            WeightEntry(measuredAt: Fixtures.start, weightKg: 80),
            WeightEntry(measuredAt: Fixtures.start.addingTimeInterval(60), weightKg: 84),
            WeightEntry(measuredAt: day6, weightKg: 78),
            WeightEntry(measuredAt: now.addingTimeInterval(86400), weightKg: 50)
        ]
        let summary = ProgressSummary(entries: entries, initialWeight: 90, targetWeight: 80,
                                      now: now, calendar: calendar)
        XCTAssertEqual(summary.currentWeight, 78)
        XCTAssertEqual(summary.sevenDayAverage, 80)
        XCTAssertEqual(summary.changeFromStart, -12)
        XCTAssertEqual(summary.targetProgress, 1)
    }

    func testEmptyProgressAndEqualTargetHaveNoDivisionByZero() {
        let empty = ProgressSummary(entries: [], initialWeight: 80, targetWeight: 80)
        XCTAssertNil(empty.sevenDayAverage)
        let now = Date()
        let same = ProgressSummary(entries: [WeightEntry(measuredAt: now, weightKg: 80)],
                                   initialWeight: 80, targetWeight: 80, now: now)
        XCTAssertNil(same.targetProgress)
    }
}
