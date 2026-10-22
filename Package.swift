// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FitFlowCore",
    platforms: [.macOS(.v13), .iOS(.v17)],
    products: [.library(name: "FitFlowCore", targets: ["FitFlowCore"])],
    targets: [
        .target(
            name: "FitFlowCore",
            path: "FitFlow",
            exclude: [
                "Assets.xcassets", "Constants/Localizable.xcstrings", "Constants/Enum/LocalizableEnum.swift",
                "ContentView.swift", "FitFlowApp.swift", "FitFlow.entitlements", "Extension", "Shared", "View",
                "Core/Coordinator", "Core/DependencyContainer.swift",
                "Core/Manager/HealthManager.swift", "Core/Manager/StorageManager.swift",
                "Model/ActivityLog.swift"
            ],
            sources: [
                "Model/AIWorkoutResponse.swift", "Model/DailyWorkout.swift", "Model/Exercise.swift",
                "Model/MacroGoals.swift", "Model/UserProfile.swift", "Model/Workout.swift",
                "Model/MealPlan.swift", "Model/MealPlanDay.swift", "Model/WorkoutPlan.swift",
                "Model/WorkoutPlanDay.swift", "Model/WeeklyPlan.swift", "Model/WeightEntry.swift",
                "Core/Manager/AIConfiguration.swift", "Core/Manager/GeminiManager.swift",
                "Core/Manager/PlanSchema.swift", "Core/Manager/PlanValidator.swift",
                "Core/Manager/PlanRepository.swift", "Core/Manager/TrackingManager.swift",
                "Constants/Enum/StorageEnum.swift"
            ]
        ),
        .testTarget(name: "FitFlowCoreTests", dependencies: ["FitFlowCore"],
                    path: "Tests/FitFlowCoreTests", resources: [.copy("Fixtures")])
    ]
)
