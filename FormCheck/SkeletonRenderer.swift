//
//  SkeletonRenderer.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation
import Vision

/// Renders skeleton lines connecting body joints
final class SkeletonRenderer {
    
    // MARK: - Properties
    
    /// Reference to the preview layer for adding skeleton layer
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Single reusable shape layer for skeleton lines
    private let skeletonLayer: CAShapeLayer
    
    /// Joint connection definitions (limb segments)
    private let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        // Head to shoulders (neck)
        (.nose, .leftShoulder),
        (.nose, .rightShoulder),
        
        // Left arm
        (.leftShoulder, .leftElbow),
        (.leftElbow, .leftWrist),
        
        // Right arm
        (.rightShoulder, .rightElbow),
        (.rightElbow, .rightWrist),
        
        // Torso - left side
        (.leftShoulder, .leftHip),
        (.leftHip, .leftKnee),
        (.leftKnee, .leftAnkle),
        
        // Torso - right side
        (.rightShoulder, .rightHip),
        (.rightHip, .rightKnee),
        (.rightKnee, .rightAnkle)
    ]
    
    /// Whether skeleton rendering is enabled
    var isEnabled: Bool = true {
        didSet {
            skeletonLayer.isHidden = !isEnabled
        }
    }
    
    // MARK: - Initialization
    
    /// Initializes the skeleton renderer
    /// - Parameter previewLayer: The camera preview layer to add skeleton overlay to
    init(previewLayer: AVCaptureVideoPreviewLayer?) {
        self.previewLayer = previewLayer
        
        // Create skeleton layer
        self.skeletonLayer = CAShapeLayer()
        self.skeletonLayer.strokeColor = UIColor.systemGreen.cgColor
        self.skeletonLayer.fillColor = UIColor.clear.cgColor
        self.skeletonLayer.lineWidth = 3.0
        self.skeletonLayer.lineCap = .round
        self.skeletonLayer.lineJoin = .round
        
        // Add to preview layer
        if let previewLayer = previewLayer {
            previewLayer.addSublayer(skeletonLayer)
        }
    }
    
    // MARK: - Public Methods
    
    /// Updates the skeleton visualization with current pose data
    /// - Parameters:
    ///   - poseData: Current pose data containing joint positions
    ///   - color: Color for the skeleton lines (e.g., green for good form, red for bad)
    func updateSkeleton(poseData: PoseData, color: UIColor) {
        guard isEnabled else { return }
        
        // Create new path for skeleton lines
        let path = UIBezierPath()
        
        // Draw each connection if both joints are available
        for (startJoint, endJoint) in connections {
            guard let startPoint = poseData.jointPositions[startJoint],
                  let endPoint = poseData.jointPositions[endJoint] else {
                // One or both joints missing, skip this connection
                continue
            }
            
            // Draw line from start to end
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        // Update layer with new path and color
        skeletonLayer.path = path.cgPath
        skeletonLayer.strokeColor = color.cgColor
    }
    
    /// Clears the skeleton visualization
    func clear() {
        skeletonLayer.path = nil
    }
    
    /// Removes the skeleton layer from the preview
    func removeFromSuperlayer() {
        skeletonLayer.removeFromSuperlayer()
    }
    
    // MARK: - Configuration
    
    /// Updates the line width of skeleton lines
    /// - Parameter width: Line width in points
    func setLineWidth(_ width: CGFloat) {
        skeletonLayer.lineWidth = width
    }
    
    /// Updates the opacity of skeleton lines
    /// - Parameter opacity: Opacity value (0.0 - 1.0)
    func setOpacity(_ opacity: Float) {
        skeletonLayer.opacity = opacity
    }
}

