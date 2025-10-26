//
//  ExerciseData.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Model representing exercise information
struct Exercise {
    let name: String
    let description: String
    let primaryMuscles: String
    let secondaryMuscles: String
    let tutorialImageName: String
    let animationAssetName: String
    let buttonIconName: String
    let buttonColor: UIColor
}

/// Exercise data manager
struct ExerciseDataSource {
    static let allExercises: [Exercise] = [
        Exercise(
            name: "Barbell Back Squats",
            description: "Barbell back squats are a fundamental lower body exercise that primarily targets the quadriceps, hamstrings, glutes, and core muscles. It involves lowering your body by bending at the hips and knees while keeping a barbell balanced on your upper back, then returning to a standing position. Proper form is crucial to maximize effectiveness and prevent injury. Ideally, your shoulders should remain on top of your feet throughout the movement, with your knees tracking over your toes and your back maintaining a neutral position.",
            primaryMuscles: "Quadriceps, Hamstrings, Glutes",
            secondaryMuscles: "Adductors, Calves, Lower Back, Core",
            tutorialImageName: "quadriceps_muscles",
            animationAssetName: "squat_animation",
            buttonIconName: "figure.strengthtraining.traditional",
            buttonColor: .systemOrange
        ),
        Exercise(
            name: "Free Bodyweight Squats",
            description: "Free bodyweight squats are an excellent exercise for building lower body strength without any equipment. They target your quadriceps, hamstrings, glutes, and core muscles. This exercise is perfect for beginners and can be performed anywhere. Focus on maintaining proper form: keep your back straight, lower your hips as if sitting in a chair, and ensure your knees track over your toes. Push through your heels to return to standing position.",
            primaryMuscles: "Quadriceps, Glutes, Hamstrings",
            secondaryMuscles: "Core, Calves, Lower Back",
            tutorialImageName: "quadriceps_muscles",
            animationAssetName: "squat_animation",
            buttonIconName: "figure.squat",
            buttonColor: UIColor(red: 0.36, green: 0.36, blue: 1.0, alpha: 1.0) // Blue-purple color
        )
    ]
    
    static func getExercise(byName name: String) -> Exercise? {
        return allExercises.first { $0.name == name }
    }
}
