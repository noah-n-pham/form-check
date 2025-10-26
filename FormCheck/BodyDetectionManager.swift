//
//  BodyDetectionManager.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import Vision

/// Manages body detection state and tracking
final class BodyDetectionManager {
    
    // MARK: - Properties
    
    /// Timestamp of last valid full body detection
    private var lastValidDetectionTime: Date?
    
    /// Counter for consecutive frames without full body detection
    private var consecutiveFramesWithoutBody: Int = 0
    
    /// Critical joints for side view detection (at least one from each pair must be visible)
    private let criticalJointPairs: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        (.leftShoulder, .rightShoulder),
        (.leftHip, .rightHip),
        (.leftKnee, .rightKnee),
        (.leftAnkle, .rightAnkle)
    ]
    
    /// Maximum time since last valid detection (2 seconds)
    private let maxTimeSinceDetection: TimeInterval = 2.0
    
    /// Maximum consecutive frames without body before showing guide (30 frames)
    private let maxConsecutiveFramesWithoutBody: Int = 30
    
    // MARK: - Public Methods
    
    /// Updates detection state based on current pose data
    /// - Parameter poseData: Current pose data from Vision framework
    /// - Returns: true if body is properly detected (critical joints visible for side view)
    func updateDetectionState(poseData: PoseData) -> Bool {
        let currentTime = Date()
        
        // For side view, we need at least one joint from each critical pair (shoulder, hip, knee, ankle)
        // Since left/right joints overlap in side view, we only need one from each pair
        var pairsDetected = 0
        
        for (leftJoint, rightJoint) in criticalJointPairs {
            let leftDetected = isJointValid(leftJoint, in: poseData)
            let rightDetected = isJointValid(rightJoint, in: poseData)
            
            // At least one joint from this pair must be detected
            if leftDetected || rightDetected {
                pairsDetected += 1
            }
        }
        
        // Consider body detected if we have at least 3 out of 4 critical pairs
        // (shoulder, hip, knee, ankle - can miss one due to occlusion)
        let hasValidBody = pairsDetected >= 3
        
        if hasValidBody {
            // Body detected - update timestamp and reset counter
            lastValidDetectionTime = currentTime
            consecutiveFramesWithoutBody = 0
            return true
        } else {
            // Not enough joints detected - increment counter
            consecutiveFramesWithoutBody += 1
            
            // Check if we have recent valid detection (within last 2 seconds)
            if let lastDetection = lastValidDetectionTime {
                let timeSinceDetection = currentTime.timeIntervalSince(lastDetection)
                if timeSinceDetection <= maxTimeSinceDetection {
                    // Recent detection exists, still considered "detected"
                    return true
                }
            }
            
            return false
        }
    }
    
    /// Checks if a joint is detected with sufficient confidence
    private func isJointValid(_ jointName: VNHumanBodyPoseObservation.JointName, in poseData: PoseData) -> Bool {
        guard let confidence = poseData.confidences[jointName] else {
            return false
        }
        return confidence >= FormCheckConstants.CONFIDENCE_THRESHOLD
    }
    
    /// Checks if positioning guide should be shown
    /// - Returns: true if guide should be displayed
    func shouldShowPositioningGuide() -> Bool {
        let currentTime = Date()
        
        // Show guide if no recent valid detection
        if let lastDetection = lastValidDetectionTime {
            let timeSinceDetection = currentTime.timeIntervalSince(lastDetection)
            if timeSinceDetection > maxTimeSinceDetection {
                return true
            }
        } else {
            // Never had a valid detection
            return true
        }
        
        // Show guide if too many consecutive frames without body
        if consecutiveFramesWithoutBody >= maxConsecutiveFramesWithoutBody {
            return true
        }
        
        return false
    }
    
    /// Resets the detection state (useful when view appears)
    func reset() {
        lastValidDetectionTime = nil
        consecutiveFramesWithoutBody = 0
    }
    
    // MARK: - Getters
    
    /// Get time since last valid detection
    var timeSinceLastDetection: TimeInterval? {
        guard let lastDetection = lastValidDetectionTime else {
            return nil
        }
        return Date().timeIntervalSince(lastDetection)
    }
    
    /// Get consecutive frames without body count
    var framesWithoutBody: Int {
        return consecutiveFramesWithoutBody
    }
}

