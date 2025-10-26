//
//  CameraTestViewController.swift
//  FormCheck
//
//  Created for GatorHack - Visual Testing Interface
//

import UIKit
import AVFoundation
import Vision

/// Visual testing interface for camera and pose detection system
/// Shows colored keypoint overlays and debug information
final class CameraTestViewController: UIViewController {
    
    // MARK: - Camera Manager
    
    private let cameraPoseManager = CameraPoseManager()
    
    // MARK: - Body Detection Manager
    
    private let bodyDetectionManager = BodyDetectionManager()
    
    // MARK: - Skeleton Renderer
    
    private var skeletonRenderer: SkeletonRenderer?
    
    // MARK: - Keypoint Layers (Reusable)
    
    private var keypointLayers: [VNHumanBodyPoseObservation.JointName: CAShapeLayer] = [:]
    
    // MARK: - Debug UI
    
    private let debugLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let skeletonToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skeleton: ON", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let positioningGuideView: PositioningGuideView = {
        let view = PositioningGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - FPS Tracking
    
    private var lastUpdateTime: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var currentFPS: Double = 0
    
    // MARK: - Joint Colors (Squat Analysis Focus)
    
    private let jointColors: [VNHumanBodyPoseObservation.JointName: UIColor] = [
        // Core squat analysis joints only
        .leftShoulder: .systemBlue,
        .rightShoulder: .systemBlue,
        .leftHip: .systemGreen,
        .rightHip: .systemGreen,
        .leftKnee: .systemRed,
        .rightKnee: .systemRed,
        .leftAnkle: .systemYellow,
        .rightAnkle: .systemYellow
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Camera Test"
        
        setupUI()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bodyDetectionManager.reset()
        positioningGuideView.show(animated: false)
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
    
    private func setupUI() {
        // Add positioning guide (full screen overlay)
        view.addSubview(positioningGuideView)
        NSLayoutConstraint.activate([
            positioningGuideView.topAnchor.constraint(equalTo: view.topAnchor),
            positioningGuideView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            positioningGuideView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            positioningGuideView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add debug label
        view.addSubview(debugLabel)
        NSLayoutConstraint.activate([
            debugLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            debugLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            debugLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Add skeleton toggle button
        view.addSubview(skeletonToggleButton)
        skeletonToggleButton.addTarget(self, action: #selector(toggleSkeletonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            skeletonToggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skeletonToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            skeletonToggleButton.widthAnchor.constraint(equalToConstant: 130),
            skeletonToggleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add back button
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 120),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Initialize keypoint layers for all joints
        for (jointName, color) in jointColors {
            let layer = createKeypointLayer(color: color)
            keypointLayers[jointName] = layer
            view.layer.addSublayer(layer)
        }
        
        // Initial debug text
        updateDebugLabel(jointCount: 0, avgConfidence: 0)
    }
    
    private func setupCamera() {
        cameraPoseManager.delegate = self
        
        cameraPoseManager.setupCamera(in: view) { [weak self] success, errorMessage in
            if success {
                print("✅ Camera test setup successful")
                
                // Setup skeleton renderer after camera is ready
                self?.setupSkeletonRenderer()
            } else {
                print("❌ Camera test setup failed: \(errorMessage ?? "Unknown error")")
                self?.showCameraError(errorMessage ?? "Failed to setup camera")
            }
        }
    }
    
    private func setupSkeletonRenderer() {
        // Initialize skeleton renderer with preview layer
        skeletonRenderer = SkeletonRenderer(previewLayer: cameraPoseManager.getPreviewLayer())
        skeletonRenderer?.isEnabled = true
    }
    
    // MARK: - Keypoint Layer Creation
    
    private func createKeypointLayer(color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let diameter: CGFloat = 10.0
        let radius = diameter / 2.0
        
        // Create circle path
        let path = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        layer.path = path.cgPath
        layer.fillColor = color.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2.0
        
        // Initially hidden
        layer.isHidden = true
        
        return layer
    }
    
    // MARK: - Keypoint Updates
    
    private func updateKeypoints(with poseData: PoseData) {
        // Hide all layers first
        for layer in keypointLayers.values {
            layer.isHidden = true
        }
        
        // Update positions for detected joints
        for (jointName, position) in poseData.jointPositions {
            guard let layer = keypointLayers[jointName] else { continue }
            
            // Update layer position
            layer.position = position
            layer.isHidden = false
        }
    }
    
    // MARK: - Debug Info Updates
    
    private func updateDebugLabel(jointCount: Int, avgConfidence: Float) {
        let debugText = """
          🎥 SQUAT ANALYSIS MODE
          
          Joints: \(jointCount) / 8
          Confidence: \(String(format: "%.2f", avgConfidence))
          FPS: \(String(format: "%.1f", currentFPS))
          
          🔵 Shoulders  🟢 Hips
          🔴 Knees  🟡 Ankles
        """
        
        debugLabel.text = debugText
    }
    
    private func calculateFPS() {
        let currentTime = CACurrentMediaTime()
        
        if lastUpdateTime > 0 {
            frameCount += 1
            let elapsed = currentTime - lastUpdateTime
            
            // Update FPS every second
            if elapsed >= 1.0 {
                currentFPS = Double(frameCount) / elapsed
                frameCount = 0
                lastUpdateTime = currentTime
            }
        } else {
            lastUpdateTime = currentTime
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func toggleSkeletonTapped() {
        guard let renderer = skeletonRenderer else { return }
        
        // Toggle skeleton visibility
        renderer.isEnabled.toggle()
        
        // Update button appearance
        if renderer.isEnabled {
            skeletonToggleButton.setTitle("Skeleton: ON", for: .normal)
            skeletonToggleButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        } else {
            skeletonToggleButton.setTitle("Skeleton: OFF", for: .normal)
            skeletonToggleButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        }
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
        // Calculate FPS
        calculateFPS()
        
        // Update body detection state
        let bodyDetected = bodyDetectionManager.updateDetectionState(poseData: data)
        
        // Update positioning guide visibility
        let shouldShowGuide = bodyDetectionManager.shouldShowPositioningGuide()
        if shouldShowGuide {
            positioningGuideView.show(animated: true)
        } else {
            positioningGuideView.hide(animated: true)
        }
        
        // Update keypoint visualizations
        updateKeypoints(with: data)
        
        // Update skeleton lines (green for testing, will use form color later)
        skeletonRenderer?.updateSkeleton(poseData: data, color: .systemGreen)
        
        // Calculate average confidence
        let avgConfidence: Float
        if !data.confidences.isEmpty {
            let sum = data.confidences.values.reduce(0, +)
            avgConfidence = sum / Float(data.confidences.count)
        } else {
            avgConfidence = 0
        }
        
        // Update debug info
        updateDebugLabel(jointCount: data.jointPositions.count, avgConfidence: avgConfidence)
        
        // Debug logging
        let detectionStatus = bodyDetected ? "✅" : "❌"
        print("🦴 Test Mode: \(detectionStatus) Body: \(bodyDetected) | Joints: \(data.jointPositions.count) | FPS: \(String(format: "%.1f", currentFPS))")
    }
}

