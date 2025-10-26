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
    
    /// Current rep counter
    private let repCounter = RepCounter()
    
    /// Track form issues during session
    private var issueFrequency: [String: Int] = [:]
    
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
        repCounter.reset()
        issueFrequency.removeAll()
    }
    
    /// End the current session
    /// - Returns: SessionSummary with final statistics
    func endSession() -> SessionSummary {
        let repData = repCounter.getCurrentData()
        
        // Update lifetime reps
        lifetimeReps += repData.totalReps
        UserDefaults.standard.set(lifetimeReps, forKey: lifetimeRepsKey)
        
        // Calculate most common issue
        let mostCommonIssue = issueFrequency.max(by: { $0.value < $1.value })?.key
        
        return SessionSummary(
            totalReps: repData.totalReps,
            goodFormPercentage: repData.goodFormPercentage,
            mostCommonIssue: mostCommonIssue
        )
    }
    
    /// Update session with new form analysis result
    /// - Parameter result: The current form analysis result
    func update(with result: FormAnalysisResult) {
        // Update rep counter
        repCounter.updateWithAnalysis(result)
        
        // Track form issues
        if let issue = result.primaryIssue {
            issueFrequency[issue, default: 0] += 1
        }
    }
    
    /// Get current session statistics
    /// - Returns: SessionSummary with current data
    func getCurrentStats() -> SessionSummary {
        let repData = repCounter.getCurrentData()
        let mostCommonIssue = issueFrequency.max(by: { $0.value < $1.value })?.key
        
        return SessionSummary(
            totalReps: repData.totalReps,
            goodFormPercentage: repData.goodFormPercentage,
            mostCommonIssue: mostCommonIssue
        )
    }
    
    /// Get current rep count data
    /// - Returns: RepCountData with current rep counts
    func getCurrentRepData() -> RepCountData {
        return repCounter.getCurrentData()
    }
}

