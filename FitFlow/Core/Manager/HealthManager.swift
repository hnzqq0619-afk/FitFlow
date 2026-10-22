import Foundation
import HealthKit
import Combine

@MainActor
protocol HealthStoreProtocol: AnyObject {
    var height: Double? { get }
    var weight: Double? { get }
    var birthDate: Date? { get }
    func requestAuthorization() async
}

@MainActor
final class HealthManager: ObservableObject, HealthStoreProtocol {
    private let healthStore = HKHealthStore()
    @Published private(set) var stepCount: Int?
    @Published private(set) var totalActiveEnergy: Double?
    @Published private(set) var height: Double?
    @Published private(set) var weight: Double?
    @Published private(set) var birthDate: Date?
    @Published private(set) var todayActivityLogs: [ActivityLog] = []
    @Published private(set) var totalWorkoutDuration: Double?
    @Published private(set) var todayWorkoutCount: Int?
    @Published private(set) var lastError: String?
    // This means the authorization flow was completed, NOT that reads were granted.
    @Published private(set) var accessWasRequested = UserDefaults.standard.bool(forKey: "HealthAccessWasRequested")
    private var isRefreshing = false

    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
    private let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    private var readTypes: Set<HKObjectType> {
        [stepType, energyType, heightType, weightType, HKObjectType.workoutType(),
         HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!]
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            lastError = "此设备无法提供 Apple 健康数据，请手动填写。"
            return
        }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            accessWasRequested = true
            UserDefaults.standard.set(true, forKey: "HealthAccessWasRequested")
            await refresh()
        } catch {
            lastError = "健康数据请求未完成。你可以继续手动使用。"
        }
    }

    func refresh() async {
        guard accessWasRequested, HKHealthStore.isHealthDataAvailable(), !isRefreshing else { return }
        isRefreshing = true
        lastError = nil
        defer { isRefreshing = false }
        // Empty/denied reads are represented as nil rather than claiming authorization.
        do { stepCount = try await sum(stepType, unit: .count()).map { Int($0) } }
        catch { stepCount = nil; lastError = "部分健康数据暂时无法读取。" }
        do { totalActiveEnergy = try await sum(energyType, unit: .kilocalorie()) }
        catch { totalActiveEnergy = nil; lastError = "部分健康数据暂时无法读取。" }
        do { height = try await latest(heightType, unit: .meterUnit(with: .centi)) }
        catch { height = nil }
        do { weight = try await latest(weightType, unit: .gramUnit(with: .kilo)) }
        catch { weight = nil }
        if let components = try? healthStore.dateOfBirthComponents() {
            birthDate = Calendar.current.date(from: components)
        } else { birthDate = nil }
        await fetchWorkoutLogs()
    }

    private func sum(_ type: HKQuantityType, unit: HKUnit) async throws -> Double? {
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) {
                _, result, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit)) }
            }
            healthStore.execute(query)
        }
    }

    private func latest(_ type: HKQuantityType, unit: HKUnit) async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1,
                                      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) {
                _, samples, error in
                if let error { continuation.resume(throwing: error) }
                else {
                    continuation.resume(returning: (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit))
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchWorkoutLogs() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        do {
            let workouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate,
                                          limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                    if let error { continuation.resume(throwing: error) }
                    else { continuation.resume(returning: samples as? [HKWorkout] ?? []) }
                }
                healthStore.execute(query)
            }
            todayActivityLogs = workouts.sorted { $0.startDate > $1.startDate }.map {
                ActivityLog(originalType: $0.workoutActivityType, activityName: $0.workoutActivityType.displayName,
                            calorieAmount: $0.statistics(for: self.energyType)?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0,
                            duration: $0.duration / 60, date: $0.startDate)
            }
            todayWorkoutCount = workouts.isEmpty ? nil : workouts.count
            totalWorkoutDuration = workouts.isEmpty ? nil : workouts.reduce(0) { $0 + $1.duration / 60 }
        } catch {
            todayActivityLogs = []
            todayWorkoutCount = nil
            totalWorkoutDuration = nil
            lastError = "运动记录暂时无法读取。"
        }
    }
}
