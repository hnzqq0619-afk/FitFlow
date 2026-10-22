import Foundation
import Combine

struct AppArchive: Codable {
    var schemaVersion = 1
    var profile: UserProfile?
    var initialWeight: Double?
    var plans: [WeeklyPlan] = []
    var currentPlanID: UUID?
    var weights: [WeightEntry] = []
    var completions: [WorkoutCompletion] = []
    var legacyPlan: AIWorkoutResponse?
}

@MainActor
final class PlanRepository: ObservableObject {
    @Published private(set) var archive = AppArchive()
    @Published private(set) var loadError: String?
    private var isReadOnly = false
    let fileURL: URL

    init(directory: URL? = nil, legacyDefaults: UserDefaults = .standard) {
        let root = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FitFlow", isDirectory: true)
        fileURL = root.appendingPathComponent("archive.json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let loaded = try JSONDecoder().decode(AppArchive.self, from: Data(contentsOf: fileURL))
                guard loaded.schemaVersion == 1, loaded.plans.allSatisfy({ $0.schemaVersion == 1 }) else {
                    throw AppError.message("存档版本较新，请使用兼容版本打开。")
                }
                archive = loaded
            } catch {
                isReadOnly = true
                loadError = "无法读取本地存档，已停止写入以保护原数据。请保留存档并检查备份。"
            }
        } else if let data = legacyDefaults.data(forKey: StorageEnum.savedWorkoutPlan.rawValue) {
            do {
                var migrated = AppArchive()
                migrated.legacyPlan = try JSONDecoder().decode(AIWorkoutResponse.self, from: data)
                // Old plans lack dates/profile. Preserve them without inventing either.
                try persist(migrated)
            } catch {
                loadError = "旧计划未能迁移，原 UserDefaults 数据已保留。可以填写资料创建新计划。"
            }
        }
    }

    var currentPlan: WeeklyPlan? {
        archive.plans.first { $0.id == archive.currentPlanID }
    }

    func saveProfile(_ profile: UserProfile) throws {
        try profile.validate()
        var next = archive
        next.profile = profile
        if next.initialWeight == nil { next.initialWeight = profile.weight }
        try persist(next)
    }

    func save(plan: WeeklyPlan, profile: UserProfile) throws {
        var next = archive
        next.profile = profile
        if next.initialWeight == nil { next.initialWeight = profile.weight }
        next.plans.append(plan)
        next.currentPlanID = plan.id
        try persist(next)
    }

    func selectPlan(_ id: UUID) throws {
        guard archive.plans.contains(where: { $0.id == id }) else {
            throw AppError.message("没有找到这个计划。")
        }
        var next = archive
        next.currentPlanID = id
        try persist(next)
    }

    func addWeight(_ entry: WeightEntry, now: Date = Date()) throws {
        guard entry.weightKg.isFinite, (20...500).contains(entry.weightKg), entry.measuredAt <= now else {
            throw AppError.message("请填写有效体重，记录时间不能在未来。")
        }
        if let sourceID = entry.sourceID,
           archive.weights.contains(where: { $0.source == entry.source && $0.sourceID == sourceID }) { return }
        var next = archive
        next.weights.append(entry)
        try persist(next)
    }

    func toggleCompletion(id: String, scheduledDate: Date, now: Date = Date()) throws {
        guard Calendar.current.startOfDay(for: scheduledDate) <= Calendar.current.startOfDay(for: now) else {
            throw AppError.message("未来的训练暂时不能标记完成。")
        }
        var next = archive
        if let index = next.completions.firstIndex(where: { $0.workoutID == id && $0.scheduledDate == scheduledDate }) {
            next.completions.remove(at: index)
        } else {
            next.completions.append(WorkoutCompletion(workoutID: id, scheduledDate: scheduledDate, completedAt: now))
        }
        try persist(next)
    }

    func isCompleted(id: String, scheduledDate: Date) -> Bool {
        archive.completions.contains { $0.workoutID == id && $0.scheduledDate == scheduledDate }
    }

    private func persist(_ candidate: AppArchive) throws {
        guard !isReadOnly else { throw AppError.message(loadError ?? "存档当前只读。") }
        let data = try JSONEncoder().encode(candidate)
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        #if os(iOS)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUnlessOpen])
        #else
        try data.write(to: fileURL, options: .atomic)
        #endif
        archive = candidate
    }
}
