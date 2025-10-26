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
    
    /// All rep quality scores during session
    private var sessionRepScores: [Int] = []
    
    /// All coaching cues for each rep
    private var sessionCoachingCues: [[String]] = []
    
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
        sessionRepScores.removeAll()
        sessionCoachingCues.removeAll()
    }
    
    /// End the current session
    /// - Returns: SessionSummary with final statistics
    func endSession() -> SessionSummary {
        let repData = formQualityTracker.getCurrentData()
        
        // Update lifetime reps
        lifetimeReps += repData.totalReps
        UserDefaults.standard.set(lifetimeReps, forKey: lifetimeRepsKey)
        
        return generateSessionSummary()
    }
    
    private func generateSessionSummary() -> SessionSummary {
        guard !sessionRepScores.isEmpty else {
            // No reps completed - return empty summary
            return SessionSummary(
                totalReps: 0,
                averageScore: 0,
                highestScore: 0,
                lowestScore: 0,
                allRepScores: [],
                goodFormPercentage: 0,
                mostCommonIssue: nil,
                issueCount: 0,
                performanceTrend: 0
            )
        }
        
        let totalReps = sessionRepScores.count
        let averageScore = sessionRepScores.reduce(0, +) / totalReps
        let highestScore = sessionRepScores.max() ?? 0
        let lowestScore = sessionRepScores.min() ?? 0
        let goodFormCount = sessionRepScores.filter { $0 >= 70 }.count
        let goodFormPercentage = Double(goodFormCount) / Double(totalReps) * 100
        
        // Find most common issue
        let mostCommon = cueFrequency.max(by: { $0.value < $1.value })
        let mostCommonIssue = mostCommon?.key
        let issueCount = mostCommon?.value ?? 0
        
        // Calculate performance trend (compare first half vs second half)
        let performanceTrend: Double
        if totalReps >= 4 {
            let halfPoint = totalReps / 2
            let firstHalfAvg = sessionRepScores.prefix(halfPoint).reduce(0, +) / halfPoint
            let secondHalfAvg = sessionRepScores.suffix(totalReps - halfPoint).reduce(0, +) / (totalReps - halfPoint)
            performanceTrend = Double(secondHalfAvg - firstHalfAvg)
        } else {
            performanceTrend = 0
        }
        
        return SessionSummary(
            totalReps: totalReps,
            averageScore: averageScore,
            highestScore: highestScore,
            lowestScore: lowestScore,
            allRepScores: sessionRepScores,
            goodFormPercentage: goodFormPercentage,
            mostCommonIssue: mostCommonIssue,
            issueCount: issueCount,
            performanceTrend: performanceTrend
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
    
    /// Track a completed rep with its quality and cues
    /// - Parameters:
    ///   - quality: Form quality score for the rep
    ///   - cues: Coaching cues for the rep
    func trackCompletedRep(quality: Int, cues: [String]) {
        sessionRepScores.append(quality)
        sessionCoachingCues.append(cues)
    }
    
    /// Get current session statistics
    /// - Returns: SessionSummary with current data
    func getCurrentStats() -> SessionSummary {
        return generateSessionSummary()
    }
    
    /// Get current rep count data
    /// - Returns: RepCountData with current rep counts
    func getCurrentRepData() -> RepCountData {
        return formQualityTracker.getCurrentData()
    }
}

