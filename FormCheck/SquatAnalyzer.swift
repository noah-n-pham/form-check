//
//  SquatAnalyzer.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import Vision
import CoreGraphics

/// Analyzes squat form using pose data
final class SquatAnalyzer {
    
    // MARK: - State Tracking
    
    /// Current state in the squat movement cycle
    private var currentState: SquatState = .standing
    
    /// Previous hip Y position for tracking movement direction
    private var previousHipY: CGFloat?
    
    /// Y position threshold for detecting squat depth
    private let squatDepthThreshold: CGFloat = 20.0
    
    // MARK: - Analysis Method
    
    /// Analyze squat form based on pose data
    /// - Parameter poseData: The pose data to analyze
    /// - Returns: FormAnalysisResult containing form analysis and state
    func analyzeSquat(poseData: PoseData) -> FormAnalysisResult {
        // Determine current state based on hip and knee positions
        let squatState = determineState(poseData: poseData)
        currentState = squatState
        
        // If in squat position, perform form analysis
        if squatState == .inSquat {
            return analyzeFormInSquat(poseData: poseData, state: squatState)
        } else {
            // Not in squat position, return default result
            return FormAnalysisResult(
                isGoodForm: true,
                primaryIssue: nil,
                kneeAngle: nil,
                squatState: squatState
            )
        }
    }
    
    // MARK: - Private Methods
    
    /// Determine the current squat state based on hip and knee positions
    private func determineState(poseData: PoseData) -> SquatState {
        // Extract key joint positions
        let leftHipKey = VNRecognizedPointKey(rawValue: "left_hip")
        let rightHipKey = VNRecognizedPointKey(rawValue: "right_hip")
        let leftKneeKey = VNRecognizedPointKey(rawValue: "left_knee")
        let rightKneeKey = VNRecognizedPointKey(rawValue: "right_knee")
        
        guard let leftHip = poseData.jointPositions[leftHipKey],
              let rightHip = poseData.jointPositions[rightHipKey],
              let leftKnee = poseData.jointPositions[leftKneeKey],
              let rightKnee = poseData.jointPositions[rightKneeKey] else {
            return currentState  // Maintain current state if joints not visible
        }
        
        // Average hip and knee positions
        let avgHipY = (leftHip.y + rightHip.y) / 2.0
        let avgKneeY = (leftKnee.y + rightKnee.y) / 2.0
        
        // Determine if in squat position
        // Hip drops below knee by threshold
        let hipDropAmount = avgHipY - avgKneeY
        let isInSquat = hipDropAmount > squatDepthThreshold
        
        // Determine movement direction
        var newState = currentState
        
        if let previousY = previousHipY {
            if isInSquat {
                newState = .inSquat
            } else if avgHipY > previousY {
                // Hip rising (ascending)
                if currentState == .inSquat {
                    newState = .ascending
                }
            } else if avgHipY < previousY {
                // Hip descending
                if currentState == .standing {
                    newState = .descending
                }
            }
            
            // Transition from ascending to standing
            if currentState == .ascending && !isInSquat && avgHipY <= previousY {
                newState = .standing
            }
        }
        
        previousHipY = avgHipY
        
        return newState
    }
    
    /// Analyze form while in squat position
    private func analyzeFormInSquat(poseData: PoseData, state: SquatState) -> FormAnalysisResult {
        // Extract required joints with error handling
        let leftHipKey = VNRecognizedPointKey(rawValue: "left_hip")
        let rightHipKey = VNRecognizedPointKey(rawValue: "right_hip")
        let leftKneeKey = VNRecognizedPointKey(rawValue: "left_knee")
        let rightKneeKey = VNRecognizedPointKey(rawValue: "right_knee")
        let leftAnkleKey = VNRecognizedPointKey(rawValue: "left_ankle")
        let rightAnkleKey = VNRecognizedPointKey(rawValue: "right_ankle")
        let leftShoulderKey = VNRecognizedPointKey(rawValue: "left_shoulder")
        let rightShoulderKey = VNRecognizedPointKey(rawValue: "right_shoulder")
        
        guard let leftHip = poseData.jointPositions[leftHipKey],
              let rightHip = poseData.jointPositions[rightHipKey],
              let leftKnee = poseData.jointPositions[leftKneeKey],
              let rightKnee = poseData.jointPositions[rightKneeKey],
              let leftAnkle = poseData.jointPositions[leftAnkleKey],
              let rightAnkle = poseData.jointPositions[rightAnkleKey],
              let leftShoulder = poseData.jointPositions[leftShoulderKey],
              let rightShoulder = poseData.jointPositions[rightShoulderKey] else {
            // Missing required joints
            return FormAnalysisResult(
                isGoodForm: false,
                primaryIssue: "Unable to analyze: Missing required joints",
                kneeAngle: nil,
                squatState: state
            )
        }
        
        // Calculate knee angle (average of left and right)
        let leftKneeAngle = AngleCalculator.calculateAngle(
            pointA: leftHip,
            vertex: leftKnee,
            pointC: leftAnkle
        )
        
        let rightKneeAngle = AngleCalculator.calculateAngle(
            pointA: rightHip,
            vertex: rightKnee,
            pointC: rightAnkle
        )
        
        let avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2.0
        
        // Check knee angle (priority 1)
        let isGoodKneeAngle = AngleCalculator.isAngleInRange(
            avgKneeAngle,
            min: FormCheckConstants.GOOD_KNEE_ANGLE_MIN,
            max: FormCheckConstants.GOOD_KNEE_ANGLE_MAX
        )
        
        // Check knee forward position (priority 2)
        let leftKneeForward = leftKnee.x - leftAnkle.x
        let rightKneeForward = rightKnee.x - rightAnkle.x
        let avgKneeForward = (abs(leftKneeForward) + abs(rightKneeForward)) / 2.0
        let isGoodKneePosition = avgKneeForward <= FormCheckConstants.KNEE_FORWARD_THRESHOLD
        
        // Check back angle (priority 3)
        let avgShoulder = CGPoint(
            x: (leftShoulder.x + rightShoulder.x) / 2.0,
            y: (leftShoulder.y + rightShoulder.y) / 2.0
        )
        
        let avgHip = CGPoint(
            x: (leftHip.x + rightHip.x) / 2.0,
            y: (leftHip.y + rightHip.y) / 2.0
        )
        
        let backAngle = AngleCalculator.angleFromVertical(point1: avgShoulder, point2: avgHip)
        let isGoodBackAngle = backAngle <= FormCheckConstants.BACK_ANGLE_THRESHOLD
        
        // Determine if form is good and identify primary issue
        let isGoodForm = isGoodKneeAngle && isGoodKneePosition && isGoodBackAngle
        
        var primaryIssue: String?
        
        if !isGoodForm {
            // Determine primary issue based on priority
            if !isGoodKneeAngle {
                primaryIssue = String(format: "Knee angle too %@ (%.0f°)", 
                                     avgKneeAngle < FormCheckConstants.GOOD_KNEE_ANGLE_MIN ? "small" : "large",
                                     avgKneeAngle)
            } else if !isGoodKneePosition {
                primaryIssue = "Knees too far forward"
            } else if !isGoodBackAngle {
                primaryIssue = String(format: "Back angle too large (%.0f°)", backAngle)
            }
        }
        
        return FormAnalysisResult(
            isGoodForm: isGoodForm,
            primaryIssue: primaryIssue,
            kneeAngle: avgKneeAngle,
            squatState: state
        )
    }
    
    /// Reset analyzer state
    func reset() {
        currentState = .standing
        previousHipY = nil
    }
}
