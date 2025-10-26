//
//  AudioFeedbackManager.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AudioToolbox

/// Manages audio and haptic feedback for form analysis
/// Provides alerts when poor form is detected during squats
final class AudioFeedbackManager {
    
    // MARK: - Properties
    
    /// Timestamp of the last alert played, used for debouncing
    private var lastAlertTimestamp: Date?
    
    /// Haptic feedback generator for warning notifications
    private let hapticGenerator: UINotificationFeedbackGenerator
    
    /// Minimum time interval between alerts in seconds (prevents spam)
    private let alertDebounceInterval: TimeInterval = 2.0
    
    /// Tracks the previous squat state to detect transitions
    private var previousSquatState: SquatState?
    
    // MARK: - Initialization
    
    init() {
        hapticGenerator = UINotificationFeedbackGenerator()
        hapticGenerator.prepare()
    }
    
    // MARK: - Public Methods
    
    /// Plays a form warning with both audio and haptic feedback
    /// Updates the last alert timestamp for debouncing
    func playFormWarning() {
        // Play system warning sound (1053 is a short beep)
        AudioServicesPlaySystemSound(1053)
        
        // Trigger haptic warning feedback
        hapticGenerator.notificationOccurred(.warning)
        
        // Prepare for next haptic (best practice for responsiveness)
        hapticGenerator.prepare()
        
        // Update timestamp for debouncing
        lastAlertTimestamp = Date()
    }
    
    /// Determines whether an alert should be played based on state and form
    /// - Parameters:
    ///   - currentState: The current squat state
    ///   - formIsGood: Whether the current form is good
    /// - Returns: True if alert should be played, false otherwise
    func shouldPlayAlert(currentState: SquatState, formIsGood: Bool) -> Bool {
        // Only alert on bad form
        guard !formIsGood else {
            previousSquatState = currentState
            return false
        }
        
        // Check if transitioning into 'inSquat' state
        let isTransitioningToInSquat = (previousSquatState != .inSquat && currentState == .inSquat)
        
        // Update previous state for next call
        defer { previousSquatState = currentState }
        
        // Don't alert if not transitioning into squat
        guard isTransitioningToInSquat else {
            return false
        }
        
        // Check debounce timer - at least 2 seconds must have passed
        if let lastAlert = lastAlertTimestamp {
            let timeSinceLastAlert = Date().timeIntervalSince(lastAlert)
            return timeSinceLastAlert >= alertDebounceInterval
        }
        
        // No previous alert, so we can play one
        return true
    }
    
    /// Plays an alert immediately for testing purposes
    /// Bypasses all debouncing and state checking logic
    func playTestAlert() {
        print("🔊 Playing test alert...")
        playFormWarning()
    }
    
    /// Resets the alert manager state
    /// Useful when starting a new workout session
    func reset() {
        lastAlertTimestamp = nil
        previousSquatState = nil
        hapticGenerator.prepare()
    }
}

