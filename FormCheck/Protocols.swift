//
//  Protocols.swift
//  FormCheck
//
//  Created for GatorHack
//

import Foundation

// MARK: - Pose Data Delegate

/// Delegate protocol for receiving pose detection updates
protocol PoseDataDelegate: AnyObject {
    /// Called when new pose data is detected from the camera feed
    /// - Parameter data: The detected pose data including joint positions and confidences
    func didUpdatePoseData(_ data: PoseData)
}

// MARK: - Form Analysis Delegate

/// Delegate protocol for receiving form analysis updates
protocol FormAnalysisDelegate: AnyObject {
    /// Called when form analysis is updated
    /// - Parameters:
    ///   - result: The current form analysis result
    ///   - repData: The current rep count data
    func didUpdateFormAnalysis(_ result: FormAnalysisResult, repData: RepCountData)
}

