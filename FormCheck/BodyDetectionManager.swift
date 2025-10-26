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
    
    /// Timestamp of last valid full body detection (all 8 joints)
    private var lastValidDetectionTime: Date?
    
    /// Counter for consecutive frames without full body detection
    private var consecutiveFramesWithoutBody: Int = 0
    
    /// Required joints for full body detection
    private let requiredJoints: Set<VNHumanBodyPoseObservation.JointName> = [
        .leftShoulder,
        .rightShoulder,
        .leftHip,
        .rightHip,
        .leftKnee,
        .rightKnee,
        .leftAnkle,
        .rightAnkle
    ]
    
    /// Maximum time since last valid detection (2 seconds)
    private let maxTimeSinceDetection: TimeInterval = 2.0
    
    /// Maximum consecutive frames without body before showing guide (30 frames)
    private let maxConsecutiveFramesWithoutBody: Int = 30
    
    // MARK: - Public Methods
    
    /// Updates detection state based on current pose data
    /// - Parameter poseData: Current pose data from Vision framework
    /// - Returns: true if body is properly detected (all joints present with good confidence)
    func updateDetectionState(poseData: PoseData) -> Bool {
        let currentTime = Date()
        
        // Check if all required joints are detected with sufficient confidence
        let hasAllJoints = requiredJoints.allSatisfy { jointName in
            guard let confidence = poseData.confidences[jointName] else {
                return false
            }
            return confidence >= FormCheckConstants.CONFIDENCE_THRESHOLD
        }
        
        if hasAllJoints {
            // Full body detected - update timestamp and reset counter
            lastValidDetectionTime = currentTime
            consecutiveFramesWithoutBody = 0
            return true
        } else {
            // Not all joints detected - increment counter
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

