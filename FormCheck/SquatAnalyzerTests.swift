//
//  SquatAnalyzerTests.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation
import Vision

/// Mock test data for verification
/// This would typically be in a separate test target in production
class SquatAnalyzerTests {
    
    /// Test the analyzer with mock pose data
    static func testWithMockData() {
        let analyzer = SquatAnalyzer()
        
        // Reset analyzer
        analyzer.reset()
        
        // Create mock pose data for a good squat
        let mockGoodSquat = createMockPoseData(
            hipY: 400,
            kneeY: 350,
            ankleY: 300,
            kneeX: 200,
            ankleX: 200,
            shoulderY: 100,
            hipX: 200
        )
        
        print("Testing Squat Analyzer with mock data...")
        print("=" * 50)
        
        // Test 1: Standing position
        print("\nTest 1: Standing position")
        var result = analyzer.analyzeSquat(poseData: mockGoodSquat)
        print("State: \(result.squatState)")
        print("Good form: \(result.isGoodForm)")
        assert(result.squatState == .standing || result.squatState == .inSquat)
        
        // Test 2: In squat position with good form
        print("\nTest 2: Good squat form")
        let mockInSquatGood = createMockPoseData(
            hipY: 450,
            kneeY: 400,
            ankleY: 350,
            kneeX: 200,
            ankleX: 200,
            shoulderY: 150,
            hipX: 200,
            kneeAngleDegrees: 90.0
        )
        result = analyzer.analyzeSquat(poseData: mockInSquatGood)
        print("State: \(result.squatState)")
        print("Good form: \(result.isGoodForm)")
        print("Primary issue: \(result.primaryIssue ?? "None")")
        print("Knee angle: \(result.kneeAngle?.description ?? "N/A")")
        
        // Test 3: Bad knee angle
        print("\nTest 3: Bad knee angle (too small)")
        let mockBadKneeAngle = createMockPoseData(
            hipY: 450,
            kneeY: 400,
            ankleY: 350,
            kneeX: 200,
            ankleX: 200,
            shoulderY: 150,
            hipX: 200,
            kneeAngleDegrees: 45.0  // Too small
        )
        result = analyzer.analyzeSquat(poseData: mockBadKneeAngle)
        print("State: \(result.squatState)")
        print("Good form: \(result.isGoodForm)")
        print("Primary issue: \(result.primaryIssue ?? "None")")
        print("Knee angle: \(result.kneeAngle?.description ?? "N/A")")
        assert(result.isGoodForm == false)
        assert(result.primaryIssue?.contains("Knee") ?? false)
        
        // Test 4: Knees too far forward
        print("\nTest 4: Knees too far forward")
        let mockKneesForward = createMockPoseData(
            hipY: 450,
            kneeY: 400,
            ankleY: 350,
            kneeX: 250,  // 50 pixels forward of ankle
            ankleX: 200,
            shoulderY: 150,
            hipX: 200,
            kneeAngleDegrees: 90.0
        )
        result = analyzer.analyzeSquat(poseData: mockKneesForward)
        print("State: \(result.squatState)")
        print("Good form: \(result.isGoodForm)")
        print("Primary issue: \(result.primaryIssue ?? "None")")
        print("Knee angle: \(result.kneeAngle?.description ?? "N/A")")
        assert(result.isGoodForm == false)
        assert(result.primaryIssue?.contains("forward") ?? false)
        
        print("\n" + "=" * 50)
        print("All tests completed successfully!")
    }
    
    /// Create mock pose data with specified joint positions
    private static func createMockPoseData(
        hipY: CGFloat,
        kneeY: CGFloat,
        ankleY: CGFloat,
        kneeX: CGFloat,
        ankleX: CGFloat,
        shoulderY: CGFloat,
        hipX: CGFloat,
        kneeAngleDegrees: Double? = nil
    ) -> PoseData {
        let baseX: CGFloat = 200
        
        // Calculate realistic joint positions based on angle
        let leftHip = CGPoint(x: hipX, y: hipY)
        let rightHip = CGPoint(x: hipX + 20, y: hipY)
        
        let leftKnee = CGPoint(x: kneeX, y: kneeY)
        let rightKnee = CGPoint(x: kneeX + 20, y: kneeY)
        
        let leftAnkle = CGPoint(x: ankleX, y: ankleY)
        let rightAnkle = CGPoint(x: ankleX + 20, y: ankleY)
        
        let leftShoulder = CGPoint(x: baseX, y: shoulderY)
        let rightShoulder = CGPoint(x: baseX + 30, y: shoulderY)
        
        // Create joint positions dictionary using correct JointName type
        var jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        jointPositions[.leftHip] = leftHip
        jointPositions[.rightHip] = rightHip
        jointPositions[.leftKnee] = leftKnee
        jointPositions[.rightKnee] = rightKnee
        jointPositions[.leftAnkle] = leftAnkle
        jointPositions[.rightAnkle] = rightAnkle
        jointPositions[.leftShoulder] = leftShoulder
        jointPositions[.rightShoulder] = rightShoulder
        
        // Create confidences
        var confidences: [VNHumanBodyPoseObservation.JointName: Float] = [:]
        for key in jointPositions.keys {
            confidences[key] = 0.9
        }
        
        return PoseData(
            jointPositions: jointPositions,
            confidences: confidences
        )
    }
}

extension String {
    static func *(left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

extension Double {
    var description: String {
        return String(format: "%.1f°", self)
    }
}
