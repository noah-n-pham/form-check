//
//  FormQualityTracker.swift
//  FormCheck
//
//  Science-based form quality rating system
//

import Foundation

/// Tracks form quality ratings across reps
final class FormQualityTracker {
    
    // MARK: - Properties
    
    /// Total number of reps completed
    private(set) var totalReps: Int = 0
    
    /// Sum of all rep quality scores (for calculating average)
    private var totalQualityScore: Int = 0
    
    /// Last completed rep's quality score
    private(set) var lastRepQuality: Int?
    
    /// Last completed rep's coaching cues
    private(set) var lastRepCues: [String] = []
    
    /// Previous squat state for detecting state transitions
    private var previousState: SquatState = .standing
    
    /// Accumulated quality scores during current rep
    private var repQualityScores: [Int] = []
    
    /// Accumulated coaching cues during current rep
    private var repCoachingCues: [[String]] = []
    
    /// Track if user actually went through inSquat phase
    private var wentThroughSquatPhase: Bool = false
    
    /// Track if user attempted a squat movement
    private var attemptedSquatMovement: Bool = false
    
    // MARK: - Public Methods
    
    /// Update tracker with new analysis result
    /// - Parameter result: The current form analysis result
    func updateWithAnalysis(_ result: FormAnalysisResult) {
        let currentState = result.squatState
        
        // Track that we started a squat attempt
        if currentState == .descending {
            attemptedSquatMovement = true
        }
        
        // Track form quality during squat phase
        if currentState == .inSquat {
            wentThroughSquatPhase = true
            
            // Collect quality scores and cues
            repQualityScores.append(result.formQuality)
            repCoachingCues.append(result.coachingCues)
            
            print("📊 Rep Quality Tracker: Score \(result.formQuality)/100 (\(repQualityScores.count) frames)")
        }
        
        // Detect complete cycle: ascending → standing
        if previousState == .ascending && currentState == .standing {
            if wentThroughSquatPhase {
                // FULL REP: Reached proper depth
                totalReps += 1
                
                // Calculate average quality for this rep
                let avgRepQuality = repQualityScores.isEmpty ? 0 : Int(Double(repQualityScores.reduce(0, +)) / Double(repQualityScores.count))
                
                // Aggregate coaching cues (most frequent)
                let allCues = repCoachingCues.flatMap { $0 }
                let cueCounts = Dictionary(grouping: allCues, by: { $0 }).mapValues { $0.count }
                let dominantCues = cueCounts.filter { $0.value > repCoachingCues.count / 3 }  // Cue appears in >33% of frames
                    .sorted { $0.value > $1.value }
                    .map { $0.key }
                
                // Store last rep data
                lastRepQuality = avgRepQuality
                lastRepCues = Array(dominantCues.prefix(3))  // Max 3 cues
                
                // Update running totals
                totalQualityScore += avgRepQuality
                
                print("✅ REP #\(totalReps) COMPLETED: Quality \(avgRepQuality)/100")
                if !lastRepCues.isEmpty {
                    print("   📋 Coaching: \(lastRepCues.joined(separator: ", "))")
                }
                
            } else if attemptedSquatMovement {
                // PARTIAL REP: Didn't reach depth - count as low quality
                totalReps += 1
                lastRepQuality = 30  // Low score for partial rep
                lastRepCues = ["GO DEEPER"]
                totalQualityScore += 30
                
                print("⚠️  REP #\(totalReps) PARTIAL: Quality 30/100 (insufficient depth)")
            }
            
            // Reset tracking for next attempt
            wentThroughSquatPhase = false
            attemptedSquatMovement = false
            repQualityScores = []
            repCoachingCues = []
        }
        
        // Reset tracking when starting new descent
        if previousState == .standing && currentState == .descending {
            wentThroughSquatPhase = false
            attemptedSquatMovement = true
            repQualityScores = []
            repCoachingCues = []
            print("🔄 Starting new squat attempt")
        }
        
        previousState = currentState
    }
    
    /// Get current tracking data
    /// - Returns: RepCountData with current statistics
    func getCurrentData() -> RepCountData {
        let avgQuality = totalReps > 0 ? totalQualityScore / totalReps : 0
        return RepCountData(
            totalReps: totalReps,
            averageFormQuality: avgQuality,
            lastRepQuality: lastRepQuality,
            lastRepCues: lastRepCues
        )
    }
    
    /// Reset all tracking
    func reset() {
        totalReps = 0
        totalQualityScore = 0
        lastRepQuality = nil
        lastRepCues = []
        previousState = .standing
        repQualityScores = []
        repCoachingCues = []
        wentThroughSquatPhase = false
        attemptedSquatMovement = false
        print("🔄 Form quality tracker reset")
    }
}

