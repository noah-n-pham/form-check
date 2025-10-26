//
//  CameraTestViewController.swift
//  FormCheck
//
//  Created for GatorHack
//  Visual testing interface for camera and pose detection system
//

import UIKit
import AVFoundation
import Vision

/// Test view controller to visualize pose detection with colored keypoint overlays
final class CameraTestViewController: UIViewController {
    
    // MARK: - Camera Manager
    
    private let cameraPoseManager = CameraPoseManager()
    
    // MARK: - Debug Overlay
    
    private let debugLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Keypoint Layers (Reusable)
    
    private var keypointLayers: [VNHumanBodyPoseObservation.JointName: CAShapeLayer] = [:]
    
    // MARK: - FPS Tracking
    
    private var lastUpdateTime: CFTimeInterval = 0
    private var fpsValues: [Double] = []
    private let maxFpsValues = 30 // Track last 30 frames for averaging
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Camera Test"
        
        // Setup back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // Set up camera manager delegate
        cameraPoseManager.delegate = self
        
        // Setup camera
        setupCamera()
        
        // Setup debug overlay
        setupDebugOverlay()
        
        // Create reusable keypoint layers
        createKeypointLayers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraPoseManager.startCapture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraPoseManager.stopCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update preview layer frame when view layout changes
        cameraPoseManager.getPreviewLayer()?.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        cameraPoseManager.setupCamera(in: view) { [weak self] success, errorMessage in
            if success {
                print("✅ Camera test setup successful")
            } else {
                print("❌ Camera test setup failed: \(errorMessage ?? "Unknown error")")
                self?.showCameraError(errorMessage ?? "Failed to setup camera")
            }
        }
    }
    
    private func setupDebugOverlay() {
        view.addSubview(debugLabel)
        
        NSLayoutConstraint.activate([
            debugLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            debugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            debugLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        debugLabel.text = "Waiting for pose detection..."
    }
    
    private func createKeypointLayers() {
        // Create reusable CAShapeLayers for each joint
        let joints: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]
        
        for joint in joints {
            let layer = CAShapeLayer()
            layer.fillColor = colorForJoint(joint).cgColor
            layer.isHidden = true // Hidden until we have data
            view.layer.addSublayer(layer)
            keypointLayers[joint] = layer
        }
    }
    
    // MARK: - Color Mapping
    
    private func colorForJoint(_ joint: VNHumanBodyPoseObservation.JointName) -> UIColor {
        switch joint {
        case .leftShoulder, .rightShoulder:
            return .systemBlue // Blue for shoulders
        case .leftHip, .rightHip:
            return .systemGreen // Green for hips
        case .leftKnee, .rightKnee:
            return .systemRed // Red for knees
        case .leftAnkle, .rightAnkle:
            return .systemYellow // Yellow for ankles
        default:
            return .white
        }
    }
    
    // MARK: - Keypoint Visualization
    
    private func updateKeypointVisuals(_ poseData: PoseData) {
        // Update each keypoint layer
        for (joint, layer) in keypointLayers {
            if let position = poseData.jointPositions[joint] {
                // Update position and make visible
                let diameter: CGFloat = 10.0
                let radius = diameter / 2.0
                let rect = CGRect(
                    x: position.x - radius,
                    y: position.y - radius,
                    width: diameter,
                    height: diameter
                )
                layer.path = UIBezierPath(ovalIn: rect).cgPath
                layer.isHidden = false
            } else {
                // Hide if joint not detected
                layer.isHidden = true
            }
        }
    }
    
    // MARK: - Debug Info
    
    private func updateDebugInfo(_ poseData: PoseData) {
        // Calculate FPS
        let currentTime = CACurrentMediaTime()
        if lastUpdateTime > 0 {
            let timeDiff = currentTime - lastUpdateTime
            let instantFps = 1.0 / timeDiff
            fpsValues.append(instantFps)
            if fpsValues.count > maxFpsValues {
                fpsValues.removeFirst()
            }
        }
        lastUpdateTime = currentTime
        
        // Calculate average FPS
        let avgFps = fpsValues.isEmpty ? 0 : fpsValues.reduce(0, +) / Double(fpsValues.count)
        
        // Calculate average confidence
        let confidenceSum = poseData.confidences.values.reduce(0, +)
        let avgConfidence = poseData.confidences.isEmpty ? 0 : confidenceSum / Float(poseData.confidences.count)
        
        // Get joint count
        let jointCount = poseData.jointPositions.count
        
        // Build debug text
        let debugText = """
        📊 POSE DETECTION TEST
        
        Joints Detected: \(jointCount) / 8
        Avg Confidence: \(String(format: "%.2f", avgConfidence))
        FPS: \(String(format: "%.1f", avgFps))
        
        Detected Joints:
        \(formatDetectedJoints(poseData))
        """
        
        debugLabel.text = debugText
        
        // Add padding
        debugLabel.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private func formatDetectedJoints(_ poseData: PoseData) -> String {
        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]
        
        var lines: [String] = []
        for joint in jointNames {
            let name = friendlyJointName(joint)
            let emoji = emojiForJoint(joint)
            
            if let confidence = poseData.confidences[joint] {
                lines.append("  \(emoji) \(name): \(String(format: "%.2f", confidence))")
            } else {
                lines.append("  ❌ \(name): not detected")
            }
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func friendlyJointName(_ joint: VNHumanBodyPoseObservation.JointName) -> String {
        switch joint {
        case .leftShoulder: return "L Shoulder"
        case .rightShoulder: return "R Shoulder"
        case .leftHip: return "L Hip"
        case .rightHip: return "R Hip"
        case .leftKnee: return "L Knee"
        case .rightKnee: return "R Knee"
        case .leftAnkle: return "L Ankle"
        case .rightAnkle: return "R Ankle"
        default: return "Unknown"
        }
    }
    
    private func emojiForJoint(_ joint: VNHumanBodyPoseObservation.JointName) -> String {
        switch joint {
        case .leftShoulder, .rightShoulder: return "🔵"
        case .leftHip, .rightHip: return "🟢"
        case .leftKnee, .rightKnee: return "🔴"
        case .leftAnkle, .rightAnkle: return "🟡"
        default: return "⚪️"
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Error Handling
    
    private func showCameraError(_ message: String) {
        let alert = UIAlertController(
            title: "Camera Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - PoseDataDelegate

extension CameraTestViewController: PoseDataDelegate {
    func didUpdatePoseData(_ data: PoseData) {
        // Update keypoint visuals
        updateKeypointVisuals(data)
        
        // Update debug info
        updateDebugInfo(data)
    }
}

// MARK: - UILabel Extension for Text Insets

private extension UILabel {
    var textContainerInset: UIEdgeInsets {
        get {
            return .zero
        }
        set {
            // Workaround: Add padding by adjusting text with attributed string
            guard let text = self.text else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            paragraphStyle.lineBreakMode = self.lineBreakMode
            
            let attributedString = NSAttributedString(
                string: "\n\(text)\n",
                attributes: [
                    .font: self.font ?? .systemFont(ofSize: 14),
                    .foregroundColor: self.textColor ?? .white,
                    .paragraphStyle: paragraphStyle
                ]
            )
            self.attributedText = attributedString
        }
    }
}

