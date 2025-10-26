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
    /// This is the interior angle at the knee (hip-knee-ankle)
    /// 90° = parallel (thighs parallel to ground)
    /// 70° = below parallel (deep squat)
    static let GOOD_KNEE_ANGLE_MIN = 70.0
    
    /// Maximum knee angle (degrees) for good squat form at bottom position
    /// Must reach at least parallel depth to be considered a proper squat
    /// 95° = at-parallel depth (proper squat standard)
    /// Angles above 95° indicate quarter squats (improper depth)
    static let GOOD_KNEE_ANGLE_MAX = 95.0
    
    // MARK: - Positional Thresholds (Normalized by Body Proportions)
    
    /// Maximum allowed knee forward position as percentage of shin length
    /// Measured as (knee_forward_distance / shin_length) × 100
    /// ~45% of shin length allows natural forward travel in proper squats
    /// This scales automatically with user height and camera distance
    /// Note: Knees going forward is NATURAL in squats - this threshold allows proper form
    static let KNEE_FORWARD_THRESHOLD_PERCENT = 45.0
    
    /// Maximum allowed back angle from vertical (degrees)
    /// Shoulder-hip angle from vertical should not exceed this
    /// For barbell back squats, some forward lean is natural and acceptable
    static let BACK_ANGLE_THRESHOLD = 50.0
    
    // MARK: - Detection Thresholds
    
    /// Minimum confidence threshold for joint detection (0.0-1.0)
    /// Only joints with confidence above this value are used
    /// Lowered to 0.45 for better stability in real-world conditions
    static let CONFIDENCE_THRESHOLD: Float = 0.45
    
    // MARK: - Performance Settings
    
    /// Target frames per second for pose detection processing
    static let TARGET_FPS = 15
    
    /// Camera resolution width
    static let CAMERA_WIDTH = 1280
    
    /// Camera resolution height
    static let CAMERA_HEIGHT = 720
}

