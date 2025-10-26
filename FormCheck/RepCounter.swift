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
            
            // Track form quality during squat phase
            // If form is bad at ANY point during inSquat, mark entire rep as bad
            if !result.isGoodForm {
                wasFormGoodDuringSquat = false
                print("📊 Rep Tracker: Form is BAD during squat - will count as bad rep")
            }
        }
        
        // Detect complete cycle: ascending → standing
        if previousState == .ascending && currentState == .standing {
            if wentThroughSquatPhase {
                // FULL REP: Reached proper depth
                totalReps += 1
                
                // Categorize based on form quality
                if wasFormGoodDuringSquat {
                    goodFormReps += 1
                    print("✅ FULL REP COUNTED: #\(totalReps) - GOOD FORM")
                } else {
                    badFormReps += 1
                    print("❌ FULL REP COUNTED: #\(totalReps) - BAD FORM")
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
        }
        
        // Reset tracking when starting new descent
        if previousState == .standing && currentState == .descending {
            wasFormGoodDuringSquat = true
            wentThroughSquatPhase = false
            attemptedSquatMovement = true
            print("🔄 Starting new squat attempt")
        }
        
        previousState = currentState
    }
    
    /// Get current rep count data
    /// - Returns: RepCountData with current statistics
    func getCurrentData() -> RepCountData {
        return RepCountData(
            totalReps: totalReps,
            goodFormReps: goodFormReps,
            badFormReps: badFormReps,
            partialReps: partialReps
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
        print("🔄 Rep counter reset")
    }
}

