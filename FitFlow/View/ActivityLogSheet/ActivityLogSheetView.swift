import SwiftUI

struct ActivityLogSheet: View {
    @ObservedObject private var healthStore = DependencyContainer.shared.resolve(HealthManager.self)
    var body: some View {
        NavigationStack {
            List {
                if let energy = healthStore.totalActiveEnergy {
                    LabeledContent("今日活动消耗", value: String(format: "%.0f kcal", energy))
                }
                if healthStore.todayActivityLogs.isEmpty {
                    Text("没有可读取的运动记录。健康数据可以不授权，手动功能仍可使用。")
                        .foregroundStyle(.secondary)
                }
                ForEach(healthStore.todayActivityLogs) { log in
                    LabeledContent {
                        Text("\(log.duration ?? 0, specifier: "%.0f") 分钟")
                    } label: {
                        Label(log.activityName, systemImage: log.originalType.sfSymbolName)
                        Text(log.date, style: .time).font(.caption)
                    }
                }
            }
            .navigationTitle("健康活动明细")
        }
    }
}
