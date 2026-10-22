import SwiftUI

struct ProfileForm: View {
    @Binding var profile: UserProfile

    var body: some View {
        Form {
            Section("身体资料") {
                TextField("称呼（可选）", text: $profile.name)
                Picker("目标", selection: $profile.goal) {
                    ForEach(FitnessGoal.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                LabeledContent("身高（cm）") { TextField("必填", value: $profile.height, format: .number).keyboardType(.decimalPad) }
                LabeledContent("体重（kg）") { TextField("必填", value: $profile.weight, format: .number).keyboardType(.decimalPad) }
                LabeledContent("年龄") { TextField("必填", value: $profile.age, format: .number).keyboardType(.numberPad) }
                LabeledContent("目标体重（kg）") { TextField("可选", value: $profile.targetWeight, format: .number).keyboardType(.decimalPad) }
            }
            Section {
                LabeledContent("热量（kcal）") { TextField("热量", value: $profile.macros.calories, format: .number).keyboardType(.numberPad) }
                LabeledContent("蛋白质（g）") { TextField("蛋白质", value: $profile.macros.protein, format: .number).keyboardType(.numberPad) }
                LabeledContent("碳水（g）") { TextField("碳水", value: $profile.macros.carbs, format: .number).keyboardType(.numberPad) }
                LabeledContent("脂肪（g）") { TextField("脂肪", value: $profile.macros.fat, format: .number).keyboardType(.numberPad) }
            } header: {
                Text("每日营养目标")
            } footer: {
                Text("填写你已确定的目标；这些输入不会由 App 自动推算。AI 按目标安排食物，营养数值仍是估算。")
            }
            Section("中文饮食与外卖") {
                TextField("口味、常吃菜品、做饭条件", text: $profile.foodPreferences, axis: .vertical)
                TextField("过敏、忌口（无则留空）", text: $profile.allergies, axis: .vertical)
                LabeledContent("每日预算（元）") { TextField("可选", value: $profile.dailyBudget, format: .number).keyboardType(.decimalPad) }
                Stepper("每日外卖正餐：\(profile.takeawayMealsPerDay) 餐", value: $profile.takeawayMealsPerDay, in: 0...3)
            }
            Section("运动安排") {
                Stepper("每周训练：\(profile.workoutDaysPerWeek) 天", value: $profile.workoutDaysPerWeek, in: 1...7)
                Stepper("每次最多：\(profile.workoutMinutes) 分钟", value: $profile.workoutMinutes, in: 10...180, step: 5)
                TextField("器械与运动条件", text: $profile.equipment, axis: .vertical)
                Stepper("每日步数目标：\(profile.dailyStepGoal)", value: $profile.dailyStepGoal, in: 1000...30000, step: 500)
            }
            Section {
                Toggle("允许发送生成计划所需的资料", isOn: $profile.allowsAIUpload)
            } header: {
                Text("AI 数据使用")
            } footer: {
                Text("生成时会将身高、体重、年龄、目标、营养目标、预算、饮食及运动偏好发送给 Google Gemini；不发送姓名、生日或体重历史。关闭后仍可保存资料和记录体重。")
            }
        }
    }
}

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var repository: PlanRepository
    @State private var profile: UserProfile
    @State private var error: String?

    init(repository: PlanRepository) {
        self.repository = repository
        _profile = State(initialValue: repository.archive.profile ?? UserProfile())
    }
    var body: some View {
        ProfileForm(profile: $profile)
            .navigationTitle("编辑资料")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        do { try repository.saveProfile(profile); dismiss() }
                        catch { self.error = error.localizedDescription }
                    }
                }
            }
            .alert("未能保存", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("好") { error = nil }
            } message: { Text(error ?? "") }
    }
}
