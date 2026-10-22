import SwiftUI

struct DashboardView: View {
    let username: String
    @StateObject private var viewModel: DashboardViewModel
    @ObservedObject private var healthStore: HealthManager
    @ObservedObject private var repository: PlanRepository
    @State private var startDate = Date()
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var showingActivity = false
    @Environment(\.scenePhase) private var scenePhase

    init(username: String = "") {
        self.username = username
        let c = DependencyContainer.shared
        let repository = c.resolve(PlanRepository.self)
        self.repository = repository
        healthStore = c.resolve(HealthManager.self)
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            repository: repository, geminiService: c.resolve(GeminiServiceProtocol.self)))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("你好，\(viewModel.displayName)")
                    .font(.title2.bold())
                if let error = repository.loadError {
                    Text(error).foregroundStyle(.red)
                }
                HStack {
                    Button("个人资料") { showingProfile = true }
                    Button("AI 设置") { showingSettings = true }
                    NavigationLink("体重与进度") { WeightProgressView(repository: repository) }
                }
                Text("今日活动").font(.headline)
                ActivityCardView(stepCount: healthStore.stepCount, goal: viewModel.profile?.dailyStepGoal ?? 8000)
                HStack {
                    MetricChip(iconName: "flame.fill", value: healthStore.totalActiveEnergy.map { String(format: "%.0f", $0) } ?? "--",
                               unit: .kcal, label: "活动消耗", color: .red)
                    MetricChip(iconName: "clock.fill", value: healthStore.totalWorkoutDuration.map { String(format: "%.0f", $0) } ?? "--",
                               unit: .dk, label: "运动时长", color: .blue)
                    MetricChip(iconName: "figure.run", value: healthStore.todayWorkoutCount.map(String.init) ?? "--",
                               unit: .empty, label: "健康训练", color: .green)
                }
                HStack {
                    Button(healthStore.accessWasRequested ? "刷新健康数据" : "连接 Apple 健康（可选）") {
                        Task {
                            if healthStore.accessWasRequested { await healthStore.refresh() }
                            else { await healthStore.requestAuthorization() }
                        }
                    }
                    Button("活动明细") { showingActivity = true }
                }
                Text("未读取到数据时显示 --。你可以随时手动填写资料、记录体重。")
                    .font(.caption).foregroundStyle(.secondary)
                if let error = healthStore.lastError { Text(error).font(.caption).foregroundStyle(.secondary) }
                if let profile = viewModel.profile { NutritionGoalCard(goals: profile.macros) }
                GroupBox("七天饮食与每周运动") {
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker("计划开始", selection: $startDate,
                                   in: Calendar.current.startOfDay(for: Date())..., displayedComponents: .date)
                        Button(viewModel.isLoadingPlan ? "正在生成…" : "生成新的七天计划") {
                            viewModel.generate(startDate: startDate)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoadingPlan || viewModel.profile == nil)
                        if viewModel.isLoadingPlan { ProgressView() }
                        if let error = viewModel.lastError { Text(error).foregroundStyle(.red) }
                        if viewModel.profile == nil {
                            Text("先填写资料即可生成计划；旧计划仍可浏览。")
                        }
                        if !viewModel.plans.isEmpty {
                            Menu("切换历史计划") {
                                ForEach(viewModel.plans) { plan in
                                    Button("\(PlanDates.key(plan.mealPlan.startDate)) · \(plan.createdAt.formatted(date: .abbreviated, time: .shortened))") {
                                        viewModel.selectPlan(plan.id)
                                    }
                                }
                            }
                        }
                        if let plan = viewModel.currentPlan {
                            Text("开始：\(PlanDates.key(plan.mealPlan.startDate)) · 时区：\(plan.mealPlan.timeZoneID)")
                                .font(.caption).foregroundStyle(.secondary)
                        } else if viewModel.workoutPlan != nil {
                            Text("旧计划未记录具体日期；请保存资料后生成新计划。").font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let plan = viewModel.workoutPlan { AIWorkoutSection(plan: plan) }
                else { Text("尚无计划。你也可以先到「体重与进度」开始记录。").foregroundStyle(.secondary) }
            }
            .padding()
        }
        .navigationTitle("我的减脂助手")
        .sheet(isPresented: $showingProfile) { NavigationStack { ProfileEditorView(repository: repository) } }
        .sheet(isPresented: $showingSettings) { NavigationStack { AISettingsView() } }
        .sheet(isPresented: $showingActivity) { ActivityLogSheet().presentationDetents([.medium, .large]) }
        .task { if healthStore.accessWasRequested { await healthStore.refresh() } }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, healthStore.accessWasRequested { Task { await healthStore.refresh() } }
        }
        .onDisappear { viewModel.cancelGeneration() }
    }
}
