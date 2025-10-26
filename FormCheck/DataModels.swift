//
//  DataModels.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import Vision
import CoreGraphics

// MARK: - Pose Data

/// Represents detected pose data from Vision framework
struct PoseData {
    /// Dictionary mapping joint keypoints to their screen coordinates
    let jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint]
    
    /// Dictionary mapping joint keypoints to their confidence values (0.0-1.0)
    let confidences: [VNHumanBodyPoseObservation.JointName: Float]
    
    init(jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint], confidences: [VNHumanBodyPoseObservation.JointName: Float]) {
        self.jointPositions = jointPositions
        self.confidences = confidences
    }
}

// MARK: - Squat State

/// Represents the current state of a squat movement
enum SquatState {
    case standing
    case descending
    case inSquat
    case ascending
}

// MARK: - Form Analysis Result

/// Result of analyzing squat form at a given moment
struct FormAnalysisResult {
    /// Whether the current form meets all quality thresholds
    let isGoodForm: Bool
    
    /// Primary form issue if any, nil if form is good
    let primaryIssue: String?
    
    /// Array of ALL detected form issues (empty if form is good)
    let allIssues: [String]
    
    /// Calculated knee angle in degrees, nil if not calculable
    let kneeAngle: Double?
    
    /// Current state in the squat movement cycle
    let squatState: SquatState
    
    init(isGoodForm: Bool, primaryIssue: String?, allIssues: [String] = [], kneeAngle: Double?, squatState: SquatState) {
        self.isGoodForm = isGoodForm
        self.primaryIssue = primaryIssue
        self.allIssues = allIssues
        self.kneeAngle = kneeAngle
        self.squatState = squatState
    }
    
    /// User-friendly feedback message showing all issues or success
    var feedbackMessage: String {
        if isGoodForm {
            return "Good form! ✓"
        } else if allIssues.isEmpty {
            return primaryIssue ?? "Check your form"
        } else {
            // Show all issues
            return allIssues.joined(separator: " | ")
        }
    }
}

// MARK: - Rep Count Data

/// Tracks repetition counts and performance metrics
struct RepCountData {
    /// Total number of full reps completed
    let totalReps: Int
    
    /// Number of reps with good form
    let goodFormReps: Int
    
    /// Number of reps with bad form
    let badFormReps: Int
    
    /// Number of partial reps (didn't reach full depth)
    let partialReps: Int
    
    /// Total number of all attempts (full + partial)
    var totalAttempts: Int {
        return totalReps + partialReps
    }
    
    /// Percentage of full reps with good form (0-100)
    var goodFormPercentage: Double {
        guard totalReps > 0 else { return 0.0 }
        return (Double(goodFormReps) / Double(totalReps)) * 100.0
    }
    
    init(totalReps: Int, goodFormReps: Int, badFormReps: Int, partialReps: Int = 0) {
        self.totalReps = totalReps
        self.goodFormReps = goodFormReps
        self.badFormReps = badFormReps
        self.partialReps = partialReps
    }
}

// MARK: - Session Summary

/// Summary of a completed workout session
struct SessionSummary {
    /// Total number of reps completed in session
    let totalReps: Int
    
    /// Percentage of reps with good form (0-100)
    let goodFormPercentage: Double
    
    /// Most frequently occurring form issue, nil if no issues
    let mostCommonIssue: String?
    
    init(totalReps: Int, goodFormPercentage: Double, mostCommonIssue: String?) {
        self.totalReps = totalReps
        self.goodFormPercentage = goodFormPercentage
        self.mostCommonIssue = mostCommonIssue
    }
}

