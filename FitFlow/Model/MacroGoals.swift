import Foundation

struct MacroGoals: Codable, Equatable {
    // User-entered targets, not a universal nutrition prescription.
    var calories = 0
    var protein = 0
    var fat = 0
    var carbs = 0

    func validate() throws {
        guard (500...8000).contains(calories), (1...500).contains(protein),
              (1...300).contains(fat), (1...1200).contains(carbs) else {
            throw AppError.message("请填写每日热量、蛋白质、脂肪和碳水目标，不能为零。")
        }
        let macroEnergy = protein * 4 + fat * 9 + carbs * 4
        guard abs(Double(macroEnergy - calories)) / Double(calories) <= 0.2 else {
            throw AppError.message("三大营养素换算热量与热量目标相差超过 20%，请核对。")
        }
    }
}
