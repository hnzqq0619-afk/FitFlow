//
//  Workout.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

struct Workout: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let title: String
    let description: String
    let duration_min: Int
    let image_url: String?
    let exercises: [Exercise]
    
    var isCompleted: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, image_url, exercises
        case duration_min
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(duration_min)
        hasher.combine(image_url)
        hasher.combine(isCompleted)
        exercises.forEach { hasher.combine($0.id) }
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.duration_min == rhs.duration_min &&
        lhs.image_url == rhs.image_url &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.exercises.map { $0.id } == rhs.exercises.map { $0.id }
    }
}
