import SwiftUI

struct ActivityCardView: View {
    var stepCount: Int? = nil
    var goal: Int = 8000
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("今日步数").font(.headline)
                Text(stepCount.map(String.init) ?? "--").font(.largeTitle.bold())
                Text("目标：\(goal) 步").foregroundStyle(.secondary)
            }
            Spacer()
            CircularProgressView(progress: min(1, max(0, Double(stepCount ?? 0) / Double(max(1, goal)))))
        }
        .padding().background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
