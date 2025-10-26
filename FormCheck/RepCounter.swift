//
//  RepCounter.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation

/// Tracks completed reps and rep quality
final class RepCounter {
    
    // MARK: - Properties
    
    /// Total number of reps completed
    private(set) var totalReps: Int = 0
    
    /// Number of reps with good form
    private(set) var goodFormReps: Int = 0
    
    /// Number of reps with bad form
    private(set) var badFormReps: Int = 0
    
    /// Number of partial reps (didn't reach full depth)
    private(set) var partialReps: Int = 0
    
    /// Previous squat state for detecting state transitions
    private var previousState: SquatState = .standing
    
    /// Track if form was good during the squat
    private var wasFormGoodDuringSquat: Bool = true
    
    /// Count frames with good vs bad form during .inSquat
    private var goodFormFrames: Int = 0
    private var badFormFrames: Int = 0
    
    /// Track if user actually went through inSquat phase (prevents false counts)
    private var wentThroughSquatPhase: Bool = false
    
    /// Track if user attempted a squat movement (descending phase)
    private var attemptedSquatMovement: Bool = false
    
    // MARK: - Public Methods
    
    /// Update rep counter with new analysis result
    /// - Parameter result: The current form analysis result
    func updateWithAnalysis(_ result: FormAnalysisResult) {
        let currentState = result.squatState
        
        // Track that we started a squat attempt
        if currentState == .descending {
            attemptedSquatMovement = true
        }
        
        // Track that we entered the full squat phase (reached depth)
        if currentState == .inSquat {
            wentThroughSquatPhase = true
            
            // Track form quality during squat phase using majority voting
            // Count frames with good vs bad form
            if result.isGoodForm {
                goodFormFrames += 1
            } else {
                badFormFrames += 1
                print("📊 Rep Tracker: BAD form frame detected (\(badFormFrames) bad vs \(goodFormFrames) good so far)")
            }
        }
        
        // Detect complete cycle: ascending → standing
        if previousState == .ascending && currentState == .standing {
            if wentThroughSquatPhase {
                // FULL REP: Reached proper depth
                totalReps += 1
                
                // Determine form quality using majority voting (>50% good frames = good rep)
                // This prevents temporary flickering from ruining an otherwise good rep
                let totalFormFrames = goodFormFrames + badFormFrames
                let goodFormPercentage = totalFormFrames > 0 ? Double(goodFormFrames) / Double(totalFormFrames) * 100.0 : 100.0
                
                // Require >50% of frames to have good form
                let repIsGoodForm = goodFormPercentage > 50.0
                
                if repIsGoodForm {
                    goodFormReps += 1
                    print("✅ FULL REP COUNTED: #\(totalReps) - GOOD FORM (\(String(format: "%.0f", goodFormPercentage))% good frames: \(goodFormFrames)/\(totalFormFrames))")
                } else {
                    badFormReps += 1
                    print("❌ FULL REP COUNTED: #\(totalReps) - BAD FORM (\(String(format: "%.0f", goodFormPercentage))% good frames: \(goodFormFrames)/\(totalFormFrames))")
                }
                
                let totalAttempts = totalReps + partialReps
                print("📊 Rep Summary: Total Attempts: \(totalAttempts) | Full: \(totalReps) (✅\(goodFormReps) good, ❌\(badFormReps) bad) | Partial: \(partialReps)")
                
            } else if attemptedSquatMovement {
                // PARTIAL REP: Tried to squat but didn't reach depth
                partialReps += 1
                let totalAttempts = totalReps + partialReps
                print("⚠️  PARTIAL REP COUNTED: #\(totalAttempts) (didn't reach full depth)")
                print("📊 Rep Summary: Total Attempts: \(totalAttempts) | Full: \(totalReps) | Partial: \(partialReps)")
            }
            
            // Reset tracking for next attempt
            wasFormGoodDuringSquat = true
            wentThroughSquatPhase = false
            attemptedSquatMovement = false
            goodFormFrames = 0
            badFormFrames = 0
        }
        
        // Reset tracking when starting new descent
        if previousState == .standing && currentState == .descending {
            wasFormGoodDuringSquat = true
            wentThroughSquatPhase = false
            attemptedSquatMovement = true
            goodFormFrames = 0
            badFormFrames = 0
            print("🔄 Starting new squat attempt")
        }
        
        previousState = currentState
    }
    
    /// Get current rep count data
    /// - Returns: RepCountData with current statistics
    /// NOTE: This is legacy code - use FormQualityTracker instead
    func getCurrentData() -> RepCountData {
        let avgQuality = totalReps > 0 ? Int((Double(goodFormReps) / Double(totalReps)) * 100) : 0
        return RepCountData(
            totalReps: totalReps,
            averageFormQuality: avgQuality,
            lastRepQuality: nil,
            lastRepCues: []
        )
    }
    
    /// Reset all rep counts
    func reset() {
        totalReps = 0
        goodFormReps = 0
        badFormReps = 0
        partialReps = 0
        previousState = .standing
        wasFormGoodDuringSquat = true
        wentThroughSquatPhase = false
        attemptedSquatMovement = false
        goodFormFrames = 0
        badFormFrames = 0
        print("🔄 Rep counter reset")
    }
}

