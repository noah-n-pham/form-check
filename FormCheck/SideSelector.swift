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
    
    /// Hysteresis threshold - other side must be this much better (%) to switch
    private let switchThreshold: Float = 0.15  // 15% better
    
    /// Minimum acceptable average confidence for a side
    private let minAcceptableConfidence: Float = 0.6
    
    // MARK: - Public Methods
    
    /// Select the best side and filter pose data to include only that side's joints
    /// - Parameter poseData: Full pose data from camera
    /// - Returns: Filtered data with only one side, or nil if both sides are poor quality
    func selectBestSide(from poseData: PoseData) -> FilteredPoseData? {
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
        
        // Determine which side to use with hysteresis
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
    }
    
    // MARK: - Private Methods
    
    /// Calculate quality score for one side of the body
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
        // All four joints must be present
        guard let s = shoulder,
              let h = hip,
              let k = knee,
              let a = ankle,
              let sc = shoulderConf,
              let hc = hipConf,
              let kc = kneeConf,
              let ac = ankleConf else {
            return nil
        }
        
        // All joints must meet confidence threshold
        guard sc >= FormCheckConstants.CONFIDENCE_THRESHOLD,
              hc >= FormCheckConstants.CONFIDENCE_THRESHOLD,
              kc >= FormCheckConstants.CONFIDENCE_THRESHOLD,
              ac >= FormCheckConstants.CONFIDENCE_THRESHOLD else {
            return nil
        }
        
        return FilteredPoseData(
            side: side,
            shoulder: s,
            hip: h,
            knee: k,
            ankle: a,
            shoulderConf: sc,
            hipConf: hc,
            kneeConf: kc,
            ankleConf: ac
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

