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
    /// Form quality rating from 0-100 (100 = perfect form)
    let formQuality: Int
    
    /// Calculated knee angle in degrees, nil if not calculable
    let kneeAngle: Double?
    
    /// Knee forward percentage of shin length
    let kneeForwardPercent: Double?
    
    /// Back angle from vertical in degrees
    let backAngle: Double?
    
    /// Current state in the squat movement cycle
    let squatState: SquatState
    
    /// Concise coaching cues for corrections needed
    let coachingCues: [String]
    
    /// Detailed breakdown of scoring (for console logging)
    let scoreBreakdown: String?
    
    init(formQuality: Int, kneeAngle: Double?, kneeForwardPercent: Double?, backAngle: Double?, squatState: SquatState, coachingCues: [String], scoreBreakdown: String? = nil) {
        self.formQuality = formQuality
        self.kneeAngle = kneeAngle
        self.kneeForwardPercent = kneeForwardPercent
        self.backAngle = backAngle
        self.squatState = squatState
        self.coachingCues = coachingCues
        self.scoreBreakdown = scoreBreakdown
    }
    
    /// Legacy compatibility - consider form good if rating >= 70
    var isGoodForm: Bool {
        return formQuality >= 70
    }
}

// MARK: - Rep Count Data

/// Tracks repetition counts and performance metrics
struct RepCountData {
    /// Total number of full reps completed
    let totalReps: Int
    
    /// Average form quality rating across all reps (0-100)
    let averageFormQuality: Int
    
    /// Last rep's form quality rating (0-100)
    let lastRepQuality: Int?
    
    /// Last rep's coaching cues
    let lastRepCues: [String]
    
    init(totalReps: Int, averageFormQuality: Int, lastRepQuality: Int?, lastRepCues: [String]) {
        self.totalReps = totalReps
        self.averageFormQuality = averageFormQuality
        self.lastRepQuality = lastRepQuality
        self.lastRepCues = lastRepCues
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

