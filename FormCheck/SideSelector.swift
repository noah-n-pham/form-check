//
//  SideSelector.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import Vision
import CoreGraphics

/// Represents which side of the body to use for analysis
enum BodySide {
    case left
    case right
    case unknown
}

/// Filtered pose data containing only one side's joints
struct FilteredPoseData {
    let side: BodySide
    let shoulder: CGPoint
    let hip: CGPoint
    let knee: CGPoint
    let ankle: CGPoint
    let shoulderConf: Float
    let hipConf: Float
    let kneeConf: Float
    let ankleConf: Float
    
    var averageConfidence: Float {
        return (shoulderConf + hipConf + kneeConf + ankleConf) / 4.0
    }
}

/// Intelligently selects which side of the body to use for analysis and visualization
final class SideSelector {
    
    // MARK: - Properties
    
    /// Currently selected side
    private var currentSide: BodySide = .unknown
    
    /// Locked side for current rep cycle (prevents mid-rep switching)
    private var lockedSide: BodySide?
    
    /// Whether we're currently in a rep cycle (not in standing state)
    private var inRepCycle: Bool = false
    
    /// Hysteresis threshold - other side must be this much better (%) to switch
    private let switchThreshold: Float = 0.15  // 15% better
    
    /// Minimum acceptable average confidence for a side (lowered to prevent visual freezing)
    private let minAcceptableConfidence: Float = 0.55  // More lenient - prevents freezing
    
    // MARK: - Public Methods
    
    /// Select the best side and filter pose data to include only that side's joints
    /// - Parameters:
    ///   - poseData: Full pose data from camera
    ///   - squatState: Current squat state (for side locking logic)
    /// - Returns: Filtered data with only one side, or nil if both sides are poor quality
    func selectBestSide(from poseData: PoseData, squatState: SquatState? = nil) -> FilteredPoseData? {
        // Determine if we're in a rep cycle
        if let state = squatState {
            let wasInRepCycle = inRepCycle
            inRepCycle = (state != .standing)
            
            // Entering a rep cycle - lock the side
            if !wasInRepCycle && inRepCycle {
                lockedSide = currentSide
                print("🔒 Side LOCKED to \(currentSide) for this rep cycle")
            }
            
            // Exiting a rep cycle - unlock for re-evaluation
            if wasInRepCycle && !inRepCycle {
                lockedSide = nil
                print("🔓 Side UNLOCKED - can re-evaluate between reps")
            }
        }
        // Calculate quality for left side
        let leftQuality = calculateSideQuality(
            shoulder: poseData.jointPositions[.leftShoulder],
            hip: poseData.jointPositions[.leftHip],
            knee: poseData.jointPositions[.leftKnee],
            ankle: poseData.jointPositions[.leftAnkle],
            shoulderConf: poseData.confidences[.leftShoulder],
            hipConf: poseData.confidences[.leftHip],
            kneeConf: poseData.confidences[.leftKnee],
            ankleConf: poseData.confidences[.leftAnkle],
            side: .left
        )
        
        // Calculate quality for right side
        let rightQuality = calculateSideQuality(
            shoulder: poseData.jointPositions[.rightShoulder],
            hip: poseData.jointPositions[.rightHip],
            knee: poseData.jointPositions[.rightKnee],
            ankle: poseData.jointPositions[.rightAnkle],
            shoulderConf: poseData.confidences[.rightShoulder],
            hipConf: poseData.confidences[.rightHip],
            kneeConf: poseData.confidences[.rightKnee],
            ankleConf: poseData.confidences[.rightAnkle],
            side: .right
        )
        
        // If side is locked during rep cycle, use locked side
        if let locked = lockedSide {
            switch locked {
            case .left:
                if let left = leftQuality {
                    return left  // Use locked side even if other is better
                }
                // Locked side unavailable, try other
                return rightQuality
            case .right:
                if let right = rightQuality {
                    return right  // Use locked side even if other is better
                }
                // Locked side unavailable, try other
                return leftQuality
            case .unknown:
                break  // Proceed to normal selection
            }
        }
        
        // Not locked - determine which side to use with hysteresis
        let selectedSide = selectSideWithHysteresis(
            leftQuality: leftQuality,
            rightQuality: rightQuality
        )
        
        // Create filtered data for selected side
        switch selectedSide {
        case .left:
            return leftQuality
        case .right:
            return rightQuality
        case .unknown:
            return nil  // Both sides have poor quality
        }
    }
    
    /// Get currently selected side
    var selectedSide: BodySide {
        return currentSide
    }
    
    /// Reset side selection
    func reset() {
        currentSide = .unknown
        lockedSide = nil
        inRepCycle = false
        print("🔄 Side selector reset - side unlocked")
    }
    
    // MARK: - Private Methods
    
    /// Calculate quality score for one side of the body
    /// More lenient - allows 3 out of 4 joints for robustness
    private func calculateSideQuality(
        shoulder: CGPoint?,
        hip: CGPoint?,
        knee: CGPoint?,
        ankle: CGPoint?,
        shoulderConf: Float?,
        hipConf: Float?,
        kneeConf: Float?,
        ankleConf: Float?,
        side: BodySide
    ) -> FilteredPoseData? {
        // Collect available joints with good confidence
        var goodJoints: [(point: CGPoint, conf: Float, type: String)] = []
        
        if let s = shoulder, let sc = shoulderConf, sc >= FormCheckConstants.CONFIDENCE_THRESHOLD {
            goodJoints.append((s, sc, "shoulder"))
        }
        if let h = hip, let hc = hipConf, hc >= FormCheckConstants.CONFIDENCE_THRESHOLD {
            goodJoints.append((h, hc, "hip"))
        }
        if let k = knee, let kc = kneeConf, kc >= FormCheckConstants.CONFIDENCE_THRESHOLD {
            goodJoints.append((k, kc, "knee"))
        }
        if let a = ankle, let ac = ankleConf, ac >= FormCheckConstants.CONFIDENCE_THRESHOLD {
            goodJoints.append((a, ac, "ankle"))
        }
        
        // Require at least 3 out of 4 joints (more robust to temporary occlusion)
        guard goodJoints.count >= 3 else {
            return nil
        }
        
        // For critical joints (hip, knee, ankle for squat analysis), must have all 3
        let hasHip = hip != nil && (hipConf ?? 0) >= FormCheckConstants.CONFIDENCE_THRESHOLD
        let hasKnee = knee != nil && (kneeConf ?? 0) >= FormCheckConstants.CONFIDENCE_THRESHOLD
        let hasAnkle = ankle != nil && (ankleConf ?? 0) >= FormCheckConstants.CONFIDENCE_THRESHOLD
        
        guard hasHip && hasKnee && hasAnkle else {
            // Missing critical joint for squat analysis
            return nil
        }
        
        // Use actual joint values (shoulder can be missing if we have hip/knee/ankle)
        let finalShoulder = shoulder ?? hip!  // Use hip as fallback if shoulder missing
        let finalShoulderConf = shoulderConf ?? hipConf!
        
        return FilteredPoseData(
            side: side,
            shoulder: finalShoulder,
            hip: hip!,
            knee: knee!,
            ankle: ankle!,
            shoulderConf: finalShoulderConf,
            hipConf: hipConf!,
            kneeConf: kneeConf!,
            ankleConf: ankleConf!
        )
    }
    
    /// Select side with hysteresis to prevent jittery switching
    private func selectSideWithHysteresis(
        leftQuality: FilteredPoseData?,
        rightQuality: FilteredPoseData?
    ) -> BodySide {
        // If only one side is available, use it
        if leftQuality != nil && rightQuality == nil {
            currentSide = .left
            return .left
        }
        
        if rightQuality != nil && leftQuality == nil {
            currentSide = .right
            return .right
        }
        
        // If neither side is available
        guard let left = leftQuality, let right = rightQuality else {
            return .unknown
        }
        
        // Both sides available - apply hysteresis
        let leftConf = left.averageConfidence
        let rightConf = right.averageConfidence
        
        // Check if either side meets minimum acceptable confidence
        if leftConf < minAcceptableConfidence && rightConf < minAcceptableConfidence {
            // Both sides have poor quality
            return .unknown
        }
        
        // Apply hysteresis based on current selection
        switch currentSide {
        case .left:
            // Currently using left - only switch if right is significantly better
            if rightConf > leftConf + switchThreshold {
                currentSide = .right
                print("🔄 Side Switch: LEFT → RIGHT (conf: \(String(format: "%.2f", leftConf)) → \(String(format: "%.2f", rightConf)))")
                return .right
            } else {
                // Stay with left
                return .left
            }
            
        case .right:
            // Currently using right - only switch if left is significantly better
            if leftConf > rightConf + switchThreshold {
                currentSide = .left
                print("🔄 Side Switch: RIGHT → LEFT (conf: \(String(format: "%.2f", rightConf)) → \(String(format: "%.2f", leftConf)))")
                return .left
            } else {
                // Stay with right
                return .right
            }
            
        case .unknown:
            // No current preference - pick the better side
            if leftConf >= rightConf {
                currentSide = .left
                print("📍 Initial Side Selection: LEFT (conf: \(String(format: "%.2f", leftConf)))")
                return .left
            } else {
                currentSide = .right
                print("📍 Initial Side Selection: RIGHT (conf: \(String(format: "%.2f", rightConf)))")
                return .right
            }
        }
    }
}

