//
//  ActivityLog.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import Foundation
import HealthKit

struct ActivityLog: Identifiable {
    let id = UUID()
    let originalType: HKWorkoutActivityType
    let activityName: String
    let calorieAmount: Double
    let duration: Double?
    let date: Date
}

