import SwiftUI

struct PhysicalInfoView: View {
    @Binding var height: Double?
    @Binding var weight: Double?
    @Binding var age: Int?
    var isButtonDisabled: Bool
    var body: some View {
        VStack(spacing: 16) {
            TextField("身高（cm）", value: $height, format: .number).keyboardType(.decimalPad)
            TextField("体重（kg）", value: $weight, format: .number).keyboardType(.decimalPad)
            TextField("年龄", value: $age, format: .number).keyboardType(.numberPad)
        }
        .textFieldStyle(.roundedBorder)
        .disabled(isButtonDisabled)
    }
}
