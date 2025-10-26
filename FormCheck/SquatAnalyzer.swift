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
    
    // MARK: - Components
    
    /// Smart side selector for choosing best quality side
    private let sideSelector = SideSelector()
    
    // MARK: - State Tracking
    
    /// Current state in the squat movement cycle
    private var currentState: SquatState = .standing
    
    /// Previous hip Y position for tracking movement direction
    private var previousHipY: CGFloat?
    
    /// Y position threshold for detecting squat depth (adjusted for side view at 5-7 feet)
    /// Hip must drop at least 50 pixels below knee to be considered "in squat"
    private let squatDepthThreshold: CGFloat = 50.0
    
    /// Frame counter for state stability (prevents bouncing)
    private var stateFrameCounter: Int = 0
    private let minFramesForStateChange: Int = 5  // Require 5 consecutive frames (0.33s at 15 FPS)
    
    /// Pending state waiting for confirmation
    private var pendingState: SquatState?
    
    /// Throttle console logging to make it readable
    private var lastLogTime: Date = Date()
    private let logInterval: TimeInterval = 0.5  // Log every 0.5 seconds
    
    // MARK: - Adaptive Standing Detection
    
    /// Baseline hip-to-ankle distance when standing (calibrated after first rep)
    private var standingBaseline: CGFloat?
    
    /// Fixed threshold for first rep (safe fallback)
    private let fixedStandingThreshold: CGFloat = 270.0
    
    /// Minimum hip-to-ankle drop to validate a proper squat
    private let minSquatDepthDrop: CGFloat = 100.0  // Must drop by 100px to be a real squat
    
    // MARK: - Analysis Method
    
    /// Analyze squat form based on pose data
    /// - Parameter poseData: The pose data to analyze
    /// - Returns: FormAnalysisResult containing form analysis and state
    func analyzeSquat(poseData: PoseData) -> FormAnalysisResult {
        // Select best side using smart side selector
        guard let filteredData = sideSelector.selectBestSide(from: poseData) else {
            // No good side available
            return FormAnalysisResult(
                isGoodForm: false,
                primaryIssue: "Unable to analyze: Poor joint detection quality",
                kneeAngle: nil,
                squatState: currentState
            )
        }
        
        // Determine current state based on hip and knee positions
        let squatState = determineState(filteredData: filteredData)
        
        // Log state changes clearly
        if squatState != currentState {
            print("🔄 STATE TRANSITION: \(currentState) → \(squatState)")
        }
        
        currentState = squatState
        
        // If in squat position, perform form analysis
        if squatState == .inSquat {
            print("📊 IN SQUAT STATE - Running form analysis...")
            return analyzeFormInSquat(filteredData: filteredData, state: squatState)
        } else {
            // Not in squat position, return default result
            print("⏭️  State: \(squatState) - Skipping form analysis (only runs in .inSquat)")
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
    /// Uses pre-filtered data from side selector
    private func determineState(filteredData: FilteredPoseData) -> SquatState {
        let finalHipY = filteredData.hip.y
        let finalKneeY = filteredData.knee.y
        let ankleY = filteredData.ankle.y
        
        // Use hip-to-ankle distance for depth detection (works great for side view!)
        let hipToAnkle = ankleY - finalHipY  // Distance from hip to ankle
        
        // Determine standing threshold (adaptive after first rep)
        let standingThreshold: CGFloat
        if let baseline = standingBaseline {
            // Use 85% of recorded baseline for standing detection
            standingThreshold = baseline * 0.85
        } else {
            // First rep: use fixed threshold
            standingThreshold = fixedStandingThreshold
        }
        
        // Determine if in squat depth
        // In a deep squat, hip gets much closer to ankle
        let isInSquatDepth = hipToAnkle < 150.0
        
        // Determine if in standing position (for state transitions)
        let isInStandingPosition = hipToAnkle > standingThreshold
        
        // Throttled logging - only every 0.5 seconds for readability
        let currentTime = Date()
        let shouldLog = currentTime.timeIntervalSince(lastLogTime) >= logInterval
        
        if shouldLog {
            print("\n═══════════════════════════════════════")
            print("🔍 SQUAT DEPTH (\(filteredData.side == .left ? "LEFT" : "RIGHT") side, conf: \(String(format: "%.2f", filteredData.averageConfidence))):")
            print("   Hip Y: \(Int(finalHipY))")
            print("   Knee Y: \(Int(finalKneeY))")
            print("   Ankle Y: \(Int(ankleY))")
            print("   Hip-to-Ankle Distance: \(Int(hipToAnkle))px")
            if let baseline = standingBaseline {
                print("   Standing Threshold: \(Int(standingThreshold))px (85% of baseline \(Int(baseline))px)")
            } else {
                print("   Standing Threshold: \(Int(standingThreshold))px (fixed - first rep)")
            }
            print("   📏 Squat Depth: \(isInSquatDepth ? "✅ DEEP (< 150px)" : "❌ SHALLOW (> 150px)")")
            print("   📏 Standing Position: \(isInStandingPosition ? "✅ YES (> \(Int(standingThreshold))px)" : "❌ NO")")
            print("   Current State: \(currentState)")
            lastLogTime = currentTime
        }
        
        // Determine desired state based on depth and movement
        var desiredState: SquatState
        
        if let previousY = previousHipY {
            let hipMovement = finalHipY - previousY  // Positive = moving down, Negative = moving up
            
            if shouldLog {
                print("   Hip Movement: \(String(format: "%.1f", hipMovement))px (\(hipMovement > 0 ? "↓ DOWN" : hipMovement < 0 ? "↑ UP" : "—"))")
            }
            
            // Determine desired state using improved logic
            if isInSquatDepth {
                // Deep enough for squat
                desiredState = .inSquat
                if shouldLog {
                    print("   ✅ SQUAT DEPTH REACHED - Desired State: .inSquat")
                }
            } else if isInStandingPosition {
                // Back to standing position (adaptive threshold)
                desiredState = .standing
                if shouldLog {
                    print("   🧍 Back to standing position - Desired State: .standing")
                }
            } else {
                // In between - use movement direction
                // Special case: if ascending and close to standing, assume standing (reduces bouncing)
                if currentState == .ascending && hipToAnkle > 200.0 && abs(hipMovement) < 15.0 {
                    // Close to standing with minimal movement - assume standing
                    desiredState = .standing
                    if shouldLog {
                        print("   🧍 Near standing position with minimal movement - Desired State: .standing")
                    }
                } else if hipMovement > 3.0 {
                    // Significant downward movement
                    desiredState = .descending
                    if shouldLog {
                        print("   ⬇️  Moving down - Desired State: .descending")
                    }
                } else if hipMovement < -3.0 {
                    // Significant upward movement
                    desiredState = .ascending
                    if shouldLog {
                        print("   ⬆️  Moving up - Desired State: .ascending")
                    }
                } else {
                    // Minimal movement - if ascending, assume standing; otherwise maintain
                    if currentState == .ascending {
                        desiredState = .standing
                        if shouldLog {
                            print("   🧍 Ascending with minimal movement - Desired State: .standing")
                        }
                    } else {
                        desiredState = currentState
                    }
                }
            }
        } else {
            desiredState = isInSquatDepth ? .inSquat : .standing
            print("   🆕 FIRST FRAME - Desired State: \(desiredState)")
        }
        
        // STATE STABILITY: Require state to be consistent for multiple frames before changing
        if desiredState == pendingState {
            stateFrameCounter += 1
            if shouldLog {
                print("   ⏳ Pending state '\(desiredState)' for \(stateFrameCounter)/\(minFramesForStateChange) frames")
            }
        } else {
            // Reset counter if desired state changed
            pendingState = desiredState
            stateFrameCounter = 1
            if shouldLog {
                print("   🔄 New pending state: \(desiredState) (needs \(minFramesForStateChange) frames)")
            }
        }
        
        // Only change state if we have enough consecutive frames
        var newState = currentState
        if stateFrameCounter >= minFramesForStateChange {
            newState = desiredState
            stateFrameCounter = 0
            pendingState = nil
            
            if newState != currentState {
                print("   ✨✨✨ STATE CONFIRMED & CHANGED: \(currentState) → \(newState) ✨✨✨")
                
                // ADAPTIVE CALIBRATION: Record baseline when returning to standing after a proper squat
                if newState == .standing && currentState == .ascending {
                    // User completed a rep - calibrate baseline if this was a proper squat
                    if standingBaseline == nil {
                        // First rep completed - record baseline
                        standingBaseline = hipToAnkle
                        print("📏 BASELINE CALIBRATED: \(Int(hipToAnkle))px (first rep complete)")
                        print("   Future standing threshold: \(Int(hipToAnkle * 0.85))px (85% of baseline)")
                    }
                }
            }
        }
        
        previousHipY = finalHipY
        
        if shouldLog {
            print("   Final State: \(newState)")
            print("═══════════════════════════════════════\n")
        }
        
        return newState
    }
    
    /// Analyze form while in squat position
    /// Uses pre-filtered data with best quality side
    private func analyzeFormInSquat(filteredData: FilteredPoseData, state: SquatState) -> FormAnalysisResult {
        let finalShoulder = filteredData.shoulder
        let finalHip = filteredData.hip
        let finalKnee = filteredData.knee
        let finalAnkle = filteredData.ankle
        
        print("📐 Analyzing form using \(filteredData.side == .left ? "LEFT" : "RIGHT") side (conf: \(String(format: "%.2f", filteredData.averageConfidence)))")
        
        // Calculate knee angle using the visible side
        let kneeAngle = AngleCalculator.calculateAngle(
            pointA: finalHip,
            vertex: finalKnee,
            pointC: finalAnkle
        )
        
        print("   Knee Angle: \(String(format: "%.1f°", kneeAngle))")
        
        // Check knee angle (priority 1) - scientifically correct range for full squat
        let isGoodKneeAngle = AngleCalculator.isAngleInRange(
            kneeAngle,
            min: FormCheckConstants.GOOD_KNEE_ANGLE_MIN,
            max: FormCheckConstants.GOOD_KNEE_ANGLE_MAX
        )
        
        print("   Knee Angle Good: \(isGoodKneeAngle) (range: \(FormCheckConstants.GOOD_KNEE_ANGLE_MIN)-\(FormCheckConstants.GOOD_KNEE_ANGLE_MAX)°)")
        
        // Check knee forward position (priority 2)
        // Knee should not go too far past ankle
        let kneeForward = abs(finalKnee.x - finalAnkle.x)
        let isGoodKneePosition = kneeForward <= FormCheckConstants.KNEE_FORWARD_THRESHOLD
        
        print("   Knee Forward: \(Int(kneeForward))px (threshold: \(Int(FormCheckConstants.KNEE_FORWARD_THRESHOLD))px), Good: \(isGoodKneePosition)")
        
        // Check back angle (priority 3)
        // Back should not lean too far forward
        let backAngle = AngleCalculator.angleFromVertical(point1: finalShoulder, point2: finalHip)
        let isGoodBackAngle = backAngle <= FormCheckConstants.BACK_ANGLE_THRESHOLD
        
        print("   Back Angle: \(String(format: "%.1f°", backAngle)) from vertical (threshold: \(FormCheckConstants.BACK_ANGLE_THRESHOLD)°), Good: \(isGoodBackAngle)")
        
        // Determine if form is good and collect ALL issues
        let isGoodForm = isGoodKneeAngle && isGoodKneePosition && isGoodBackAngle
        
        var allIssues: [String] = []
        var primaryIssue: String?
        
        // Check each form criterion and add specific feedback
        if !isGoodKneeAngle {
            let kneeIssue: String
            if kneeAngle < FormCheckConstants.GOOD_KNEE_ANGLE_MIN {
                kneeIssue = "Going too deep"
            } else {
                kneeIssue = "Not deep enough"
            }
            allIssues.append(kneeIssue)
            if primaryIssue == nil {
                primaryIssue = kneeIssue  // First issue becomes primary
            }
        }
        
        if !isGoodKneePosition {
            let kneePositionIssue = "Knees too far forward"
            allIssues.append(kneePositionIssue)
            if primaryIssue == nil {
                primaryIssue = kneePositionIssue
            }
        }
        
        if !isGoodBackAngle {
            let backIssue = "Keep back more upright"
            allIssues.append(backIssue)
            if primaryIssue == nil {
                primaryIssue = backIssue
            }
        }
        
        // Logging
        if isGoodForm {
            print("   Overall Form: ✅ GOOD - All checks passed!")
        } else {
            print("   Overall Form: ❌ BAD")
            print("   Issues Detected: \(allIssues.joined(separator: " | "))")
        }
        
        return FormAnalysisResult(
            isGoodForm: isGoodForm,
            primaryIssue: primaryIssue,
            allIssues: allIssues,
            kneeAngle: kneeAngle,
            squatState: state
        )
    }
    
    /// Reset analyzer state
    func reset() {
        currentState = .standing
        previousHipY = nil
        stateFrameCounter = 0
        pendingState = nil
        lastLogTime = Date()
        sideSelector.reset()
        standingBaseline = nil  // Reset adaptive baseline for new session
        print("🔄 Squat analyzer reset (baseline will recalibrate on first rep)")
    }
    
    // MARK: - Helper Methods
    
    /// Log message only if enough time has passed (for readability)
    private func logIfNeeded(_ message: String) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastLogTime) >= logInterval {
            print(message)
            lastLogTime = currentTime
        }
    }
}
