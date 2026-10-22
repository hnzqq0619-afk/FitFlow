import Foundation

struct WeightEntry: Codable, Identifiable, Equatable {
    var id = UUID()
    let measuredAt: Date
    let weightKg: Double
    var source = "manual"
    var sourceID: String?
}

struct WorkoutCompletion: Codable, Identifiable {
    var id = UUID()
    let workoutID: String
    let scheduledDate: Date
    let completedAt: Date
}

struct ProgressSummary {
    let currentWeight: Double?
    let sevenDayAverage: Double?
    let changeFromStart: Double?
    let targetProgress: Double?

    init(entries: [WeightEntry], initialWeight: Double?, targetWeight: Double?,
         now: Date = Date(), calendar: Calendar = .current) {
        let valid = entries.filter { $0.measuredAt <= now && $0.weightKg.isFinite && $0.weightKg > 0 }
            .sorted { $0.measuredAt < $1.measuredAt }
        currentWeight = valid.last?.weightKg
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
        // Average daily means, so repeated weigh-ins cannot overweight one day.
        let groups = Dictionary(grouping: valid.filter { $0.measuredAt >= start }) {
            calendar.startOfDay(for: $0.measuredAt)
        }
        let dailyMeans = groups.values.map { samples in
            samples.reduce(0.0) { $0 + $1.weightKg } / Double(samples.count)
        }
        sevenDayAverage = dailyMeans.isEmpty ? nil : dailyMeans.reduce(0, +) / Double(dailyMeans.count)
        let baseline = initialWeight ?? valid.first?.weightKg
        if let currentWeight, let baseline {
            changeFromStart = currentWeight - baseline
            if let targetWeight, baseline != targetWeight {
                targetProgress = min(1, max(0, (baseline - currentWeight) / (baseline - targetWeight)))
            } else { targetProgress = nil }
        } else {
            changeFromStart = nil
            targetProgress = nil
        }
    }
}
