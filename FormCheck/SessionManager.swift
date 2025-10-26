//
//  SessionManager.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation

/// Manages session lifecycle and persistence
final class SessionManager {
    
    // MARK: - Properties
    
    /// Session start time
    private var sessionStartTime: Date?
    
    /// Current form quality tracker
    private let formQualityTracker = FormQualityTracker()
    
    /// Track coaching cues during session
    private var cueFrequency: [String: Int] = [:]
    
    /// UserDefaults key for lifetime reps
    private let lifetimeRepsKey = "FormCheck_lifetime_reps"
    
    /// Lifetime total reps (persisted)
    private(set) var lifetimeReps: Int = 0
    
    // MARK: - Initialization
    
    init() {
        // Load lifetime reps from UserDefaults
        lifetimeReps = UserDefaults.standard.integer(forKey: lifetimeRepsKey)
    }
    
    // MARK: - Session Control
    
    /// Start a new session
    func startSession() {
        sessionStartTime = Date()
        formQualityTracker.reset()
        cueFrequency.removeAll()
    }
    
    /// End the current session
    /// - Returns: SessionSummary with final statistics
    func endSession() -> SessionSummary {
        let repData = formQualityTracker.getCurrentData()
        
        // Update lifetime reps
        lifetimeReps += repData.totalReps
        UserDefaults.standard.set(lifetimeReps, forKey: lifetimeRepsKey)
        
        // Calculate most common coaching cue
        let mostCommonCue = cueFrequency.max(by: { $0.value < $1.value })?.key
        
        return SessionSummary(
            totalReps: repData.totalReps,
            goodFormPercentage: Double(repData.averageFormQuality),
            mostCommonIssue: mostCommonCue
        )
    }
    
    /// Update session with new form analysis result
    /// - Parameter result: The current form analysis result
    func update(with result: FormAnalysisResult) {
        // Update form quality tracker
        formQualityTracker.updateWithAnalysis(result)
        
        // Track coaching cues
        for cue in result.coachingCues {
            cueFrequency[cue, default: 0] += 1
        }
    }
    
    /// Get current session statistics
    /// - Returns: SessionSummary with current data
    func getCurrentStats() -> SessionSummary {
        let repData = formQualityTracker.getCurrentData()
        let mostCommonCue = cueFrequency.max(by: { $0.value < $1.value })?.key
        
        return SessionSummary(
            totalReps: repData.totalReps,
            goodFormPercentage: Double(repData.averageFormQuality),
            mostCommonIssue: mostCommonCue
        )
    }
    
    /// Get current rep count data
    /// - Returns: RepCountData with current rep counts
    func getCurrentRepData() -> RepCountData {
        return formQualityTracker.getCurrentData()
    }
}

