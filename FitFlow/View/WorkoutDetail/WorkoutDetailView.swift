import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject private var trackingManager: TrackingManager
    @State private var error: String?
    let title: String
    let description: String
    let exercises: [ExerciseDisplayModel]
    let nutritionAdvice: String?
    let workoutId: String
    let scheduledDate: Date
    let isRestDay: Bool
    let durationMinutes: Int?

    init(workout: Workout) {
        trackingManager = DependencyContainer.shared.resolve(TrackingManager.self)
        title = workout.title; description = workout.description
        workoutId = "legacy-\(workout.id)"
        nutritionAdvice = nil
        scheduledDate = Calendar.current.startOfDay(for: Date())
        isRestDay = false
        durationMinutes = workout.duration_min
        exercises = workout.exercises.map {
            ExerciseDisplayModel(name: $0.name, sets: $0.sets, reps: $0.reps, videoUrl: $0.videoUrl)
        }
    }
    init(aiWorkout: DailyWorkout, nutrition: String?) {
        trackingManager = DependencyContainer.shared.resolve(TrackingManager.self)
        title = aiWorkout.title; description = aiWorkout.day; workoutId = aiWorkout.id.uuidString
        nutritionAdvice = nutrition
        scheduledDate = aiWorkout.scheduledDate ?? Calendar.current.startOfDay(for: Date())
        isRestDay = aiWorkout.isRestDay ?? false
        durationMinutes = aiWorkout.durationMinutes
        exercises = aiWorkout.exercises.map {
            ExerciseDisplayModel(name: $0.name, sets: $0.sets, reps: $0.reps, videoUrl: $0.videoUrl)
        }
    }

    var body: some View {
        let completed = trackingManager.isWorkoutCompleted(id: workoutId, scheduledDate: scheduledDate)
        List {
            Section("计划日期") {
                Text(description)
                if let minutes = durationMinutes, !isRestDay {
                    LabeledContent("预计时长", value: "\(minutes) 分钟")
                }
            }
            if isRestDay { Section { Text("今天是休息日，按个人状态安排轻松活动与恢复。") } }
            if let advice = nutritionAdvice { Section("饮食建议") { Text(advice) } }
            Section("动作与说明") {
                ForEach(exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name).font(.headline)
                        Text("\(exercise.sets) 组 · \(exercise.reps)").foregroundStyle(.secondary)
                        if let url = VideoLinks.url(exercise.videoUrl) {
                            Link("查看动作视频", destination: url)
                        }
                    }
                }
            }
            if !isRestDay {
                Section {
                    Button(completed ? "撤销完成" : "标记这次训练已完成") {
                        do { try trackingManager.toggleCompletion(for: workoutId, scheduledDate: scheduledDate) }
                        catch { self.error = error.localizedDescription }
                    }
                    .disabled(Calendar.current.startOfDay(for: scheduledDate) > Calendar.current.startOfDay(for: Date()))
                }
            }
        }
        .navigationTitle(title)
        .alert("未能保存", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("好") { error = nil }
        } message: { Text(error ?? "") }
    }
}

struct ExerciseDisplayModel: Identifiable {
    let id = UUID()
    let name: String
    let sets: String
    let reps: String
    let videoUrl: String?
}
