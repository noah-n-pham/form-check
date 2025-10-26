//
//  SessionSummaryPresenter.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Presents session summary results to the user
/// Displays performance metrics and provides options to continue or end session
final class SessionSummaryPresenter {
    
    // MARK: - Public Methods
    
    /// Shows a summary alert with session statistics and action options
    /// - Parameters:
    ///   - sessionData: Summary data from the completed session
    ///   - lifetimeReps: Total reps across all sessions
    ///   - onContinue: Closure called when user wants to continue the session
    ///   - onEnd: Closure called when user wants to end the session
    ///   - presentingViewController: The view controller to present the alert from
    func showSummary(
        sessionData: SessionSummary,
        lifetimeReps: Int,
        onContinue: @escaping () -> Void,
        onEnd: @escaping () -> Void,
        presentingViewController: UIViewController
    ) {
        // Create the alert controller
        let alert = UIAlertController(
            title: "Session Complete",
            message: formatSummaryMessage(sessionData: sessionData, lifetimeReps: lifetimeReps),
            preferredStyle: .alert
        )
        
        // Add "Continue Session" action
        let continueAction = UIAlertAction(
            title: "Continue Session",
            style: .default
        ) { _ in
            onContinue()
        }
        alert.addAction(continueAction)
        
        // Add "End Session" action
        let endAction = UIAlertAction(
            title: "End Session",
            style: .default
        ) { _ in
            onEnd()
        }
        alert.addAction(endAction)
        
        // Present the alert
        presentingViewController.present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    
    /// Formats the session summary message with emojis and proper spacing
    /// - Parameters:
    ///   - sessionData: Summary data from the session
    ///   - lifetimeReps: Total lifetime reps
    /// - Returns: Formatted message string
    private func formatSummaryMessage(sessionData: SessionSummary, lifetimeReps: Int) -> String {
        var message = ""
        
        // Session reps
        message += "Reps This Session: \(sessionData.totalReps)\n\n"
        
        // Good form percentage with appropriate emoji
        let formEmoji = sessionData.goodFormPercentage >= 70 ? "✅" : "⚠️"
        message += "\(formEmoji) Good Form: \(String(format: "%.1f", sessionData.goodFormPercentage))%\n\n"
        
        // Most common issue (if any)
        if let issue = sessionData.mostCommonIssue {
            message += "⚠️ Most Common Issue:\n\(issue)\n\n"
        }
        
        // Lifetime total reps
        message += "🏆 Lifetime Total: \(lifetimeReps) reps"
        
        return message
    }
}

