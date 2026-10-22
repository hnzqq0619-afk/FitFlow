import XCTest
@testable import FitFlowCore

final class RepositoryTests: XCTestCase {
    private func sandbox() throws -> (URL, UserDefaults) {
        let id = UUID().uuidString
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("FitFlowTests-\(id)")
        let defaults = UserDefaults(suiteName: "FitFlowTests-\(id)")!
        return (directory, defaults)
    }

    @MainActor
    func testPlanHistoryAndProfileSurviveRestart() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        let first = try Fixtures.plan()
        let second = try Fixtures.plan()
        try repo.save(plan: first, profile: Fixtures.profile)
        try repo.save(plan: second, profile: Fixtures.profile)
        let reopened = PlanRepository(directory: directory, legacyDefaults: defaults)
        XCTAssertEqual(reopened.archive.plans.count, 2)
        XCTAssertEqual(reopened.currentPlan?.id, second.id)
        XCTAssertEqual(reopened.archive.profile, Fixtures.profile)
        try reopened.selectPlan(first.id)
        XCTAssertEqual(reopened.currentPlan?.id, first.id)
    }

    @MainActor
    func testCompletionFullIDsDoNotCollideAndUndoPersists() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        let date = Fixtures.start
        let first = "ABCDE-11111111", second = "ABCDE-22222222"
        try repo.toggleCompletion(id: first, scheduledDate: date, now: date)
        XCTAssertFalse(repo.isCompleted(id: second, scheduledDate: date))
        try repo.toggleCompletion(id: second, scheduledDate: date, now: date)
        let reopened = PlanRepository(directory: directory, legacyDefaults: defaults)
        XCTAssertEqual(reopened.archive.completions.count, 2)
        try reopened.toggleCompletion(id: first, scheduledDate: date, now: date)
        XCTAssertFalse(reopened.isCompleted(id: first, scheduledDate: date))
        XCTAssertTrue(reopened.isCompleted(id: second, scheduledDate: date))
    }

    @MainActor
    func testFutureCompletionIsRejected() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        XCTAssertThrowsError(try repo.toggleCompletion(id: "future",
            scheduledDate: Fixtures.start.addingTimeInterval(172800), now: Fixtures.start))
        XCTAssertTrue(repo.archive.completions.isEmpty)
    }

    @MainActor
    func testCorruptArchiveIsNotOverwritten() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("archive.json")
        let original = Data("broken-private-data".utf8)
        try original.write(to: url)
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        XCTAssertNotNil(repo.loadError)
        XCTAssertThrowsError(try repo.saveProfile(Fixtures.profile))
        XCTAssertEqual(try Data(contentsOf: url), original)
    }

    @MainActor
    func testWriteFailureDoesNotChangeInMemoryProfile() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data("blocks-a-directory".utf8).write(to: directory)
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        XCTAssertThrowsError(try repo.saveProfile(Fixtures.profile))
        XCTAssertNil(repo.archive.profile)
    }

    @MainActor
    func testLegacyMigrationPreservesIDsWithoutInventingDates() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        defaults.set(try Fixtures.data, forKey: StorageEnum.savedWorkoutPlan.rawValue)
        let oldCompleted = Data(#"{"0":1234}"#.utf8)
        defaults.set(oldCompleted, forKey: StorageEnum.completedWorkouts.rawValue)
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        let legacyID = try XCTUnwrap(repo.archive.legacyPlan?.dailyPlan.first?.id)
        XCTAssertTrue(repo.archive.plans.isEmpty)
        XCTAssertTrue(repo.archive.completions.isEmpty)
        XCTAssertNil(repo.archive.profile)
        let reopened = PlanRepository(directory: directory, legacyDefaults: defaults)
        XCTAssertEqual(reopened.archive.legacyPlan?.dailyPlan.first?.id, legacyID)
        XCTAssertEqual(defaults.data(forKey: StorageEnum.completedWorkouts.rawValue), oldCompleted)
    }

    @MainActor
    func testWeightValidationAndSourceDeduplication() async throws {
        let (directory, defaults) = try sandbox()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repo = PlanRepository(directory: directory, legacyDefaults: defaults)
        let entry = WeightEntry(measuredAt: Fixtures.start, weightKg: 85, source: "healthkit", sourceID: "sample-1")
        try repo.addWeight(entry, now: Fixtures.start)
        try repo.addWeight(entry, now: Fixtures.start)
        XCTAssertEqual(repo.archive.weights.count, 1)
        XCTAssertThrowsError(try repo.addWeight(WeightEntry(measuredAt: Fixtures.start, weightKg: .nan), now: Fixtures.start))
        XCTAssertThrowsError(try repo.addWeight(WeightEntry(measuredAt: Fixtures.start.addingTimeInterval(1), weightKg: 85),
                                               now: Fixtures.start))
    }
}
