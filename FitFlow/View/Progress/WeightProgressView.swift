import SwiftUI
import Charts

struct WeightProgressView: View {
    @ObservedObject var repository: PlanRepository
    @State private var weight: Double?
    @State private var measuredAt = Date()
    @State private var error: String?

    private var entries: [WeightEntry] { repository.archive.weights.sorted { $0.measuredAt < $1.measuredAt } }
    private var summary: ProgressSummary {
        ProgressSummary(entries: entries, initialWeight: repository.archive.initialWeight,
                        targetWeight: repository.archive.profile?.targetWeight)
    }
    private func kg(_ value: Double?) -> String { value.map { String(format: "%.1f kg", $0) } ?? "--" }

    var body: some View {
        List {
            Section("记录体重") {
                TextField("体重（kg）", value: $weight, format: .number).keyboardType(.decimalPad)
                DatePicker("测量时间", selection: $measuredAt, in: ...Date())
                Button("保存记录") {
                    do {
                        guard let weight else { throw AppError.message("请先填写体重。") }
                        try repository.addWeight(WeightEntry(measuredAt: measuredAt, weightKg: weight))
                        self.weight = nil
                        measuredAt = Date()
                    } catch { self.error = error.localizedDescription }
                }
            }
            Section("减脂进度") {
                LabeledContent("最新体重", value: kg(summary.currentWeight))
                LabeledContent("最近七天平均", value: kg(summary.sevenDayAverage))
                LabeledContent("相对起点变化", value: kg(summary.changeFromStart))
                LabeledContent("目标体重", value: kg(repository.archive.profile?.targetWeight))
                if let progress = summary.targetProgress { SwiftUI.ProgressView(value: progress) }
                Text("七日平均按有记录的日期计算，同一天多次测量先取平均；缺失日期不补零。")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if !entries.isEmpty {
                Section("体重趋势") {
                    Chart(entries) {
                        LineMark(x: .value("日期", $0.measuredAt), y: .value("体重 kg", $0.weightKg))
                        PointMark(x: .value("日期", $0.measuredAt), y: .value("体重 kg", $0.weightKg))
                    }
                    .frame(height: 220)
                    .accessibilityLabel("体重随测量日期的变化")
                }
            }
            Section("训练记录") {
                Text("已记录 \(repository.archive.completions.count) 次训练完成")
            }
            Section("测量历史") {
                ForEach(entries.reversed()) { entry in
                    LabeledContent(entry.measuredAt.formatted(date: .abbreviated, time: .shortened),
                                   value: kg(entry.weightKg))
                }
            }
        }
        .navigationTitle("体重与进度")
        .alert("未能保存", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("好") { error = nil }
        } message: { Text(error ?? "") }
    }
}
