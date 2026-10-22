import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle)
            Text("操作未完成").font(.title2)
            Text(error.localizedDescription).multilineTextAlignment(.center)
            Button("重试", action: retryAction).buttonStyle(.borderedProminent)
        }.padding()
    }
}
