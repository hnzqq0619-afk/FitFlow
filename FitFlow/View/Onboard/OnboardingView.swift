import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardViewModel
    @State private var showingSettings = false

    init(coordinator: AppCoordinator) {
        let c = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: OnboardViewModel(
            coordinator: coordinator, healthStore: c.resolve(HealthStoreProtocol.self),
            geminiService: c.resolve(GeminiServiceProtocol.self), repository: c.resolve(PlanRepository.self)))
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: Double(viewModel.step), total: 3).padding(.horizontal)
            if viewModel.step == 1 {
                PersonalInfoView(name: $viewModel.profile.name).padding()
                Spacer()
            } else if viewModel.step == 2 {
                WhatIsGoalView(profileGoal: $viewModel.profile.goal).padding()
                Spacer()
            } else {
                ProfileForm(profile: $viewModel.profile)
                Button("从 Apple 健康补充未填写的资料（可选）") {
                    Task { await viewModel.importHealthData() }
                }
                .disabled(viewModel.isLoadingHealthData || viewModel.isLoadingPlan)
            }
            if let error = viewModel.lastError {
                Text(error).font(.callout).foregroundStyle(.red).padding(.horizontal)
                    .accessibilityLabel("操作失败：\(error)")
            }
            if viewModel.isLoadingPlan || viewModel.isLoadingHealthData {
                ProgressView(viewModel.isLoadingPlan ? "正在生成七天计划，可稍候重试" : "正在读取健康资料")
            }
            HStack {
                if viewModel.step > 1 {
                    Button("上一步") { viewModel.step -= 1 }
                }
                Button(viewModel.step == 3 ? "生成七天计划" : "继续", action: viewModel.nextStep)
                    .buttonStyle(.borderedProminent)
            }
            .disabled(viewModel.isLoadingPlan || viewModel.isLoadingHealthData)
            if viewModel.step == 3 {
                Button("保存资料，暂不使用 AI", action: viewModel.saveWithoutAI)
                    .disabled(viewModel.isLoadingPlan || viewModel.isLoadingHealthData)
            }
        }
        .padding(.bottom)
        .navigationTitle("设置我的资料")
        .toolbar {
            Button("AI 设置") { showingSettings = true }
        }
        .sheet(isPresented: $showingSettings) { NavigationStack { AISettingsView() } }
        .onDisappear { viewModel.cancelGeneration() }
    }
}
