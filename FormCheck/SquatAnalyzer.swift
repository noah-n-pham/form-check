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
    
    // MARK: - Adaptive Thresholds (Scale to User Size & Distance)
    
    /// Baseline hip-to-ankle distance when standing (calibrated after first rep)
    private var standingBaseline: CGFloat?
    
    /// Fixed threshold for first rep (safe fallback)
    private let fixedStandingThreshold: CGFloat = 270.0
    
    /// Squat depth as percentage of standing baseline (adaptive!)
    /// 50% means hip must get halfway to ankle from standing position
    private let squatDepthPercentage: CGFloat = 0.50  // 50% of baseline
    
    /// Fixed depth threshold for first rep before calibration
    private let fixedSquatDepthThreshold: CGFloat = 150.0
    
    // MARK: - Analysis Method
    
    /// Analyze squat form based on pose data
    /// - Parameter poseData: The pose data to analyze
    /// - Returns: FormAnalysisResult containing form analysis and state
    func analyzeSquat(poseData: PoseData) -> FormAnalysisResult {
        // Select best side using smart side selector
        guard let filteredData = sideSelector.selectBestSide(from: poseData) else {
            // No good side available
            return FormAnalysisResult(
                formQuality: 0,
                kneeAngle: nil,
                kneeForwardPercent: nil,
                backAngle: nil,
                squatState: currentState,
                coachingCues: ["POSITION BODY"],
                scoreBreakdown: "Poor joint detection"
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
                formQuality: 100,
                kneeAngle: nil,
                kneeForwardPercent: nil,
                backAngle: nil,
                squatState: squatState,
                coachingCues: []
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
        
        // Determine thresholds (adaptive after first rep)
        let standingThreshold: CGFloat
        let squatDepthThreshold: CGFloat
        
        if let baseline = standingBaseline {
            // ADAPTIVE: Scale thresholds based on user's actual size in frame
            standingThreshold = baseline * 0.85  // 85% of baseline for standing
            squatDepthThreshold = baseline * squatDepthPercentage  // 50% of baseline for squat depth
        } else {
            // First rep: use fixed thresholds (safe fallbacks)
            standingThreshold = fixedStandingThreshold
            squatDepthThreshold = fixedSquatDepthThreshold
        }
        
        // Determine if in squat depth (adaptive to user size!)
        let isInSquatDepth = hipToAnkle < squatDepthThreshold
        
        // Determine if in standing position
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
                print("   📏 ADAPTIVE THRESHOLDS (based on user size):")
                print("      Standing: \(Int(standingThreshold))px (85% of \(Int(baseline))px)")
                print("      Squat Depth: \(Int(squatDepthThreshold))px (50% of \(Int(baseline))px)")
            } else {
                print("   📏 FIXED THRESHOLDS (first rep - will calibrate):")
                print("      Standing: \(Int(standingThreshold))px")
                print("      Squat Depth: \(Int(squatDepthThreshold))px")
            }
            
            print("   Squat Status: \(isInSquatDepth ? "✅ DEEP (< \(Int(squatDepthThreshold))px)" : "❌ SHALLOW (> \(Int(squatDepthThreshold))px)")")
            print("   Standing Status: \(isInStandingPosition ? "✅ YES" : "❌ NO")")
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
                        let futureStandingThreshold = hipToAnkle * 0.85
                        let futureSquatThreshold = hipToAnkle * squatDepthPercentage
                        print("📏 BASELINE CALIBRATED: \(Int(hipToAnkle))px (first rep complete)")
                        print("   🎯 ADAPTIVE THRESHOLDS SET:")
                        print("      Standing: \(Int(futureStandingThreshold))px (85% of baseline)")
                        print("      Squat Depth: \(Int(futureSquatThreshold))px (50% of baseline)")
                        print("   ✨ System now personalized to your size & distance!")
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
    /// Returns a science-based form quality rating (0-100)
    private func analyzeFormInSquat(filteredData: FilteredPoseData, state: SquatState) -> FormAnalysisResult {
        let finalShoulder = filteredData.shoulder
        let finalHip = filteredData.hip
        let finalKnee = filteredData.knee
        let finalAnkle = filteredData.ankle
        
        print("📐 Analyzing form using \(filteredData.side == .left ? "LEFT" : "RIGHT") side (conf: \(String(format: "%.2f", filteredData.averageConfidence)))")
        print("   ═══════════════════════════════════")
        
        // Start with perfect score
        var formScore = 100
        var coachingCues: [String] = []
        var scoreBreakdown: [String] = []
        
        // 1. KNEE ANGLE (40 points max) - Most critical for depth
        let kneeAngle = AngleCalculator.calculateAngle(
            pointA: finalHip,
            vertex: finalKnee,
            pointC: finalAnkle
        )
        
        let optimalKneeMin = FormCheckConstants.GOOD_KNEE_ANGLE_MIN  // 70°
        let optimalKneeMax = FormCheckConstants.GOOD_KNEE_ANGLE_MAX  // 95°
        let kneeAngleDeduction: Int
        
        if kneeAngle < optimalKneeMin {
            // Too deep - minor issue
            let deviation = optimalKneeMin - kneeAngle
            kneeAngleDeduction = min(Int(deviation / 2.0), 15)  // Max 15 points off for going too deep
            if kneeAngleDeduction > 5 {
                coachingCues.append("LESS DEPTH")
            }
            scoreBreakdown.append("Knee angle too deep: -\(kneeAngleDeduction)")
        } else if kneeAngle > optimalKneeMax {
            // Not deep enough - major issue
            let deviation = kneeAngle - optimalKneeMax
            kneeAngleDeduction = min(Int(deviation / 1.0), 40)  // Max 40 points off for shallow squat
            if kneeAngleDeduction > 5 {
                coachingCues.append("GO DEEPER")
            }
            scoreBreakdown.append("Insufficient depth: -\(kneeAngleDeduction)")
        } else {
            // Perfect range
            kneeAngleDeduction = 0
            scoreBreakdown.append("Knee angle optimal: 0")
        }
        formScore -= kneeAngleDeduction
        
        print("   📐 Knee Angle: \(String(format: "%.1f°", kneeAngle)) | Deduction: -\(kneeAngleDeduction) pts")
        
        // 2. KNEE FORWARD POSITION (30 points max)
        let shinLength = abs(finalAnkle.y - finalKnee.y)
        let kneeForwardAbsolute = abs(finalKnee.x - finalAnkle.x)
        let kneeForwardPercent = shinLength > 0 ? (kneeForwardAbsolute / shinLength) * 100.0 : 0.0
        
        let optimalKneeForward = FormCheckConstants.KNEE_FORWARD_THRESHOLD_PERCENT  // 45%
        let kneeForwardDeduction: Int
        
        if kneeForwardPercent > optimalKneeForward {
            // Too far forward
            let deviation = kneeForwardPercent - optimalKneeForward
            kneeForwardDeduction = min(Int(deviation / 1.0), 30)  // Max 30 points off
            if kneeForwardDeduction > 10 {
                coachingCues.append("KNEES BACK")
            }
            scoreBreakdown.append("Knees too forward: -\(kneeForwardDeduction)")
        } else {
            // Within acceptable range
            kneeForwardDeduction = 0
            scoreBreakdown.append("Knee position optimal: 0")
        }
        formScore -= kneeForwardDeduction
        
        print("   📍 Knee Forward: \(String(format: "%.1f", kneeForwardPercent))% of shin | Deduction: -\(kneeForwardDeduction) pts")
        
        // 3. BACK ANGLE (30 points max)
        let backAngle = AngleCalculator.angleFromVertical(point1: finalShoulder, point2: finalHip)
        let optimalBackAngle = FormCheckConstants.BACK_ANGLE_THRESHOLD  // 50°
        let backAngleDeduction: Int
        
        if backAngle > optimalBackAngle {
            // Leaning too far forward
            let deviation = backAngle - optimalBackAngle
            backAngleDeduction = min(Int(deviation / 1.0), 30)  // Max 30 points off
            if backAngleDeduction > 10 {
                coachingCues.append("CHEST UP")
            }
            scoreBreakdown.append("Excessive forward lean: -\(backAngleDeduction)")
        } else {
            // Good upright position
            backAngleDeduction = 0
            scoreBreakdown.append("Back angle optimal: 0")
        }
        formScore -= backAngleDeduction
        
        print("   📏 Back Angle: \(String(format: "%.1f°", backAngle)) | Deduction: -\(backAngleDeduction) pts")
        
        // Ensure score stays in 0-100 range
        formScore = max(0, min(100, formScore))
        
        print("   ═══════════════════════════════════")
        print("   🎯 FORM QUALITY: \(formScore)/100")
        if !coachingCues.isEmpty {
            print("   📋 Coaching: \(coachingCues.joined(separator: ", "))")
        }
        print("   ═══════════════════════════════════")
        
        return FormAnalysisResult(
            formQuality: formScore,
            kneeAngle: kneeAngle,
            kneeForwardPercent: kneeForwardPercent,
            backAngle: backAngle,
            squatState: state,
            coachingCues: coachingCues,
            scoreBreakdown: scoreBreakdown.joined(separator: " | ")
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
