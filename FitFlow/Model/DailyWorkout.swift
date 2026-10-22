import Foundation

struct DailyWorkout: Codable, Identifiable, Hashable {
    var id = UUID()
    let day: String
    let title: String
    let exercises: [Exercise]
    var dayIndex: Int?
    var isRestDay: Bool?
    var durationMinutes: Int?
    var scheduledDate: Date?
    enum CodingKeys: String, CodingKey {
        case id, day, title, exercises, scheduledDate
        case dayIndex = "day_index", isRestDay = "is_rest_day", durationMinutes = "duration_minutes"
    }
    init(id: UUID = UUID(), day: String, title: String, exercises: [Exercise],
         dayIndex: Int? = nil, isRestDay: Bool? = nil, durationMinutes: Int? = nil,
         scheduledDate: Date? = nil) {
        self.id = id; self.day = day; self.title = title; self.exercises = exercises
        self.dayIndex = dayIndex; self.isRestDay = isRestDay
        self.durationMinutes = durationMinutes; self.scheduledDate = scheduledDate
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        day = try c.decode(String.self, forKey: .day)
        title = try c.decode(String.self, forKey: .title)
        exercises = try c.decode([Exercise].self, forKey: .exercises)
        dayIndex = try c.decodeIfPresent(Int.self, forKey: .dayIndex)
        isRestDay = try c.decodeIfPresent(Bool.self, forKey: .isRestDay)
        durationMinutes = try c.decodeIfPresent(Int.self, forKey: .durationMinutes)
        scheduledDate = try c.decodeIfPresent(Date.self, forKey: .scheduledDate)
    }
}
