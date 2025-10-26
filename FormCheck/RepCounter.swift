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
    
    /// Previous squat state for detecting state transitions
    private var previousState: SquatState = .standing
    
    /// Track if form was good during the squat
    private var wasFormGoodDuringSquat: Bool = true
    
    /// Track if user actually went through inSquat phase (prevents false counts)
    private var wentThroughSquatPhase: Bool = false
    
    // MARK: - Public Methods
    
    /// Update rep counter with new analysis result
    /// - Parameter result: The current form analysis result
    func updateWithAnalysis(_ result: FormAnalysisResult) {
        let currentState = result.squatState
        
        // Track that we entered the squat phase
        if currentState == .inSquat {
            wentThroughSquatPhase = true
            
            // Track form quality during squat phase
            // If form is bad at ANY point during inSquat, mark entire rep as bad
            if !result.isGoodForm {
                wasFormGoodDuringSquat = false
                print("📊 Rep Tracker: Form is BAD during squat - will count as bad rep")
            }
        }
        
        // Detect complete rep cycle: ascending → standing (after going through inSquat)
        if previousState == .ascending && currentState == .standing {
            // Only count if we actually went through a squat
            if wentThroughSquatPhase {
                // ALWAYS increment total reps (regardless of form quality)
                totalReps += 1
                
                // Categorize the rep based on form quality
                if wasFormGoodDuringSquat {
                    goodFormReps += 1
                    print("✅ REP COUNTED: #\(totalReps) - GOOD FORM")
                } else {
                    badFormReps += 1
                    print("❌ REP COUNTED: #\(totalReps) - BAD FORM")
                }
                
                print("📊 Rep Summary: Total: \(totalReps) | Good: \(goodFormReps) | Bad: \(badFormReps)")
            } else {
                print("⚠️  Partial movement detected - not counting as rep (didn't reach squat depth)")
            }
            
            // Reset tracking for next rep
            wasFormGoodDuringSquat = true
            wentThroughSquatPhase = false
        }
        
        // Reset form tracking when starting new descent
        if previousState == .standing && currentState == .descending {
            wasFormGoodDuringSquat = true
            wentThroughSquatPhase = false
            print("🔄 Starting new rep cycle")
        }
        
        previousState = currentState
    }
    
    /// Get current rep count data
    /// - Returns: RepCountData with current statistics
    func getCurrentData() -> RepCountData {
        return RepCountData(
            totalReps: totalReps,
            goodFormReps: goodFormReps,
            badFormReps: badFormReps
        )
    }
    
    /// Reset all rep counts
    func reset() {
        totalReps = 0
        goodFormReps = 0
        badFormReps = 0
        previousState = .standing
        wasFormGoodDuringSquat = true
        wentThroughSquatPhase = false
        print("🔄 Rep counter reset")
    }
}

