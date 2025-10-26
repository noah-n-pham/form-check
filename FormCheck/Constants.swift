//
//  Constants.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation

// MARK: - Form Analysis Constants

/// Shared constants used across the app for form analysis and thresholds
struct FormCheckConstants {
    
    // MARK: - Knee Angle Thresholds
    
    /// Minimum knee angle (degrees) for good squat form at bottom position
    static let GOOD_KNEE_ANGLE_MIN = 80.0
    
    /// Maximum knee angle (degrees) for good squat form at bottom position
    static let GOOD_KNEE_ANGLE_MAX = 100.0
    
    // MARK: - Positional Thresholds
    
    /// Maximum allowed knee forward position beyond ankle (pixels)
    /// If knee X-position exceeds ankle X-position by more than this, form is bad
    static let KNEE_FORWARD_THRESHOLD = 30.0
    
    /// Maximum allowed back angle from vertical (degrees)
    /// Shoulder-hip angle from vertical should not exceed this
    static let BACK_ANGLE_THRESHOLD = 60.0
    
    // MARK: - Detection Thresholds
    
    /// Minimum confidence threshold for joint detection (0.0-1.0)
    /// Only joints with confidence above this value are used
    static let CONFIDENCE_THRESHOLD: Float = 0.5
    
    // MARK: - Performance Settings
    
    /// Target frames per second for pose detection processing
    static let TARGET_FPS = 15
    
    /// Camera resolution width
    static let CAMERA_WIDTH = 1280
    
    /// Camera resolution height
    static let CAMERA_HEIGHT = 720
}

