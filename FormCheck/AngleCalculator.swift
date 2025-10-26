//
//  AngleCalculator.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import CoreGraphics

/// Utility class for calculating angles between points
final class AngleCalculator {
    
    /// Calculate the angle at vertex between two points
    /// - Parameters:
    ///   - pointA: First point
    ///   - vertex: Vertex point (the point at which angle is calculated)
    ///   - pointC: Second point
    /// - Returns: Angle in degrees (0-180)
    static func calculateAngle(pointA: CGPoint, vertex: CGPoint, pointC: CGPoint) -> Double {
        // Vector from vertex to pointA
        let vector1 = CGPoint(x: pointA.x - vertex.x, y: pointA.y - vertex.y)
        
        // Vector from vertex to pointC
        let vector2 = CGPoint(x: pointC.x - vertex.x, y: pointC.y - vertex.y)
        
        // Calculate dot product
        let dotProduct = (vector1.x * vector2.x) + (vector1.y * vector2.y)
        
        // Calculate magnitudes
        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
        
        // Avoid division by zero
        guard magnitude1 > 0 && magnitude2 > 0 else {
            return 0.0
        }
        
        // Calculate angle in radians using dot product formula
        let cosAngle = dotProduct / (magnitude1 * magnitude2)
        
        // Clamp cosAngle to [-1, 1] to avoid numerical errors
        let clampedCos = max(-1.0, min(1.0, cosAngle))
        
        // Convert to degrees
        let angleRadians = acos(clampedCos)
        let angleDegrees = angleRadians * 180.0 / .pi
        
        return angleDegrees
    }
    
    /// Check if an angle is within the specified range (inclusive)
    /// - Parameters:
    ///   - angle: The angle to check
    ///   - min: Minimum angle (degrees)
    ///   - max: Maximum angle (degrees)
    /// - Returns: True if angle is within range
    static func isAngleInRange(_ angle: Double, min: Double, max: Double) -> Bool {
        return angle >= min && angle <= max
    }
    
    /// Calculate the angle from vertical (straight down) for a line from point1 to point2
    /// - Parameters:
    ///   - point1: Starting point of the line (e.g., shoulder)
    ///   - point2: Ending point of the line (e.g., hip)
    /// - Returns: Angle in degrees (0-90) from vertical, where 0° is perfectly upright
    static func angleFromVertical(point1: CGPoint, point2: CGPoint) -> Double {
        // In screen coordinates, Y increases downward
        // For a vertical line (upright torso): point1.x ≈ point2.x, point2.y > point1.y
        // deltaY should be positive (hip below shoulder)
        let deltaY = point2.y - point1.y
        
        // Horizontal displacement (lean)
        let deltaX = abs(point2.x - point1.x)  // Absolute value - we only care about magnitude of lean
        
        // Calculate angle from vertical using atan2
        // atan2(horizontal, vertical) gives angle from vertical axis
        // Result: 0° = vertical, 45° = 45° lean, 90° = horizontal
        let angleRadians = atan2(deltaX, deltaY)
        let angleDegrees = angleRadians * 180.0 / .pi
        
        return angleDegrees
    }
}
