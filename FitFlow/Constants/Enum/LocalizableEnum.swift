//
//  LocalizableEnum.swift
//  FitFlow
//
//  Created by Engin Bolat on 24.12.2025.
//

import Foundation
import SwiftUI

enum LocalizableEnum: String, CaseIterable, LocalizedError, Decodable, Encodable {
    case welcomeToFitFlow
    case whatIsYourName
    case fillIntheMissingInformation
    case needDataToPreparePlan
    case age
    case height
    case weight
    case whatIsYourGoal
    case looseWeight
    case buildMuscle
    case condition
    case aiPersonalProgram
    case dailyMealPlan
    case dailyWorkoutPlan
    case generalInformation
    case focusDay
    case aiNutritionAdvice
    case exercisesDetails
    case watchFormVideo
    case undo
    case completeWorkout
    case hello
    case todaysProgramAndActivities
    case quickMetrics
    case geminiPreparingProgram
    case caloriesBurnedDetails
    case total
    case dailySteps
    case goalSteps
    case dailyNutritionGoal
    case watchPreparationVideo
    case calories
    case protein
    case carbs
    case fat
    case totalCalories
    case totalProtein
    case totalCarbs
    case totalFat
    case prepareProgram
    case continueButton
    case connectionError
    case meals
    case moreMeals
    case tryAgain
    case geminiAnalyzing
    case creatingProgram
    case mealPlan
    case next
    
    var errorDescription: String? {
        return rawValue
    }
    
    func localizedWith(suffix: String) -> LocalizedStringKey {
        let translated = NSLocalizedString(self.rawValue, comment: "")
        return LocalizedStringKey("\(translated) \(suffix)")
    }
}

extension LocalizableEnum {
    var key: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}
