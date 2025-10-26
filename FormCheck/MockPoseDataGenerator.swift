//
//  MockPoseDataGenerator.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import Vision
import CoreGraphics

/// Generates mock pose data simulating squat movements
final class MockPoseDataGenerator {
    
    // MARK: - Properties
    
    /// Current frame number in the cycle
    private var currentFrame: Int = 0
    
    /// Total frames in one squat cycle
    private let cycleFrames: Int = 60
    
    /// Whether to generate good or bad form
    private var generateGoodForm: Bool = true
    
    // MARK: - Configuration
    
    /// Set whether to generate good or bad form
    func setGenerateGoodForm(_ goodForm: Bool) {
        generateGoodForm = goodForm
    }
    
    // MARK: - Generation
    
    /// Generate next frame of pose data
    /// - Returns: PoseData for current frame
    func generateNextFrame() -> PoseData {
        let phase = currentFrame % cycleFrames
        
        var hipY: CGFloat
        var kneeY: CGFloat = 450
        let ankleY: CGFloat = 550
        let shoulderY: CGFloat = 200
        
        // Determine phase of squat cycle
        if phase < 15 {
            // Standing (frames 1-15)
            hipY = 300
        } else if phase < 30 {
            // Descending (frames 16-30)
            let progress = CGFloat(phase - 15) / 15.0
            hipY = 300 + (180 * progress)  // Move from 300 to 480
        } else if phase < 45 {
            // Bottom of squat (frames 31-45)
            hipY = 480
        } else {
            // Ascending (frames 46-60)
            let progress = CGFloat(phase - 45) / 15.0
            hipY = 480 - (180 * progress)  // Move from 480 back to 300
        }
        
        // Calculate knee position based on form quality
        var kneeX: CGFloat = 200
        let ankleX: CGFloat = 200
        
        if !generateGoodForm && phase >= 31 && phase < 45 {
            // Bad form: knees too forward during bottom phase
            kneeX = 240  // 40 pixels past ankle
        }
        
        // Create joint positions
        var jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        
        // Shoulders
        jointPositions[.leftShoulder] = CGPoint(x: 195, y: shoulderY)
        jointPositions[.rightShoulder] = CGPoint(x: 205, y: shoulderY)
        
        // Hips
        jointPositions[.leftHip] = CGPoint(x: 195, y: hipY)
        jointPositions[.rightHip] = CGPoint(x: 205, y: hipY)
        
        // Knees
        jointPositions[.leftKnee] = CGPoint(x: kneeX - 5, y: kneeY)
        jointPositions[.rightKnee] = CGPoint(x: kneeX + 5, y: kneeY)
        
        // Ankles
        jointPositions[.leftAnkle] = CGPoint(x: ankleX - 5, y: ankleY)
        jointPositions[.rightAnkle] = CGPoint(x: ankleX + 5, y: ankleY)
        
        // Arms (bonus for visualization)
        jointPositions[.nose] = CGPoint(x: 200, y: shoulderY - 50)
        jointPositions[.leftElbow] = CGPoint(x: 180, y: 300)
        jointPositions[.rightElbow] = CGPoint(x: 220, y: 300)
        jointPositions[.leftWrist] = CGPoint(x: 170, y: 350)
        jointPositions[.rightWrist] = CGPoint(x: 230, y: 350)
        
        // Create confidences (all high)
        var confidences: [VNHumanBodyPoseObservation.JointName: Float] = [:]
        for key in jointPositions.keys {
            confidences[key] = 0.9
        }
        
        currentFrame += 1
        
        return PoseData(
            jointPositions: jointPositions,
            confidences: confidences
        )
    }
    
    /// Reset generator to start of cycle
    func reset() {
        currentFrame = 0
    }
    
    /// Get current phase description
    func getCurrentPhase() -> String {
        let phase = currentFrame % cycleFrames
        
        if phase < 15 {
            return "Standing"
        } else if phase < 30 {
            return "Descending"
        } else if phase < 45 {
            return "In Squat"
        } else {
            return "Ascending"
        }
    }
}

