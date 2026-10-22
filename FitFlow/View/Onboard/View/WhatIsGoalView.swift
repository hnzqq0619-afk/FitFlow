import SwiftUI

struct WhatIsGoalView: View {
    @Binding var profileGoal: FitnessGoal
    var body: some View {
        VStack(spacing: 20) {
            Text("你的目标是什么？").font(.title2).bold()
            ForEach(FitnessGoal.allCases, id: \.self) { goal in
                Button { profileGoal = goal } label: {
                    Text(goal.title).frame(maxWidth: .infinity).padding()
                        .background(profileGoal == goal ? Color.primaryBrand : Color(.secondarySystemBackground))
                        .foregroundStyle(profileGoal == goal ? Color.white : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
