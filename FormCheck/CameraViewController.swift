//
//  CameraViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation
import Vision

/// Main camera view controller for squat analysis
final class CameraViewController: UIViewController {
    
    // MARK: - Properties (Contract Definition)
    
    /// Preview layer for displaying camera feed
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return cameraPoseManager.getPreviewLayer()
    }
    
    /// Current pose data from Vision framework
    var currentPoseData: PoseData?
    
    /// Current form analysis result
    var currentFormResult: FormAnalysisResult?
    
    /// Current rep count data
    var currentRepData: RepCountData?
    
    // MARK: - Camera Manager
    
    private let cameraPoseManager = CameraPoseManager()
    
    // MARK: - Form Analysis Components (Developer B)
    
    private let squatAnalyzer = SquatAnalyzer()
    private let repCounter = RepCounter()
    private let sideSelector = SideSelector()
    
    // MARK: - Visual Components (Developer A)
    
    private var skeletonRenderer: SkeletonRenderer?
    private let bodyDetectionManager = BodyDetectionManager()
    
    private let positioningGuideView: PositioningGuideView = {
        let view = PositioningGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - State Tracking
    
    /// Previous squat state for detecting state changes
    private var previousState: SquatState?
    
    /// Throttle console logging
    private var lastSummaryLogTime: Date = Date()
    private let summaryLogInterval: TimeInterval = 1.0  // Log summary every 1 second
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Squat Analysis"
        
        // 1. Initialize CameraPoseManager with view (already done in property)
        
        // 2. Set self as PoseDataDelegate
        cameraPoseManager.delegate = self
        
        // 3 & 4. Initialize SquatAnalyzer and RepCounter (already done in properties)
        
        // Setup UI components
        setupUI()
        
        // 5. Setup camera and start session
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bodyDetectionManager.reset()
        positioningGuideView.show(animated: false)
        startAnalysis()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnalysis()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update preview layer frame when view layout changes
        previewLayer?.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Add positioning guide (fullscreen overlay)
        view.addSubview(positioningGuideView)
        NSLayoutConstraint.activate([
            positioningGuideView.topAnchor.constraint(equalTo: view.topAnchor),
            positioningGuideView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            positioningGuideView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            positioningGuideView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Sets up the camera capture session and preview layer
    func setupCamera() {
        cameraPoseManager.setupCamera(in: view) { [weak self] success, errorMessage in
            if success {
                print("✅ Camera setup successful")
                
                // Setup skeleton renderer after camera is ready
                self?.setupSkeletonRenderer()
            } else {
                print("❌ Camera setup failed: \(errorMessage ?? "Unknown error")")
                self?.showCameraError(errorMessage ?? "Failed to setup camera")
            }
        }
    }
    
    private func setupSkeletonRenderer() {
        // Initialize skeleton renderer with preview layer
        skeletonRenderer = SkeletonRenderer(previewLayer: cameraPoseManager.getPreviewLayer())
        skeletonRenderer?.isEnabled = true
    }
    
    /// Adds an overlay component (e.g., skeleton view, feedback label) to the camera view
    /// - Parameter view: The UIView to add as an overlay
    func addOverlayComponent(_ view: UIView) {
        // Add view on top of camera preview
        self.view.addSubview(view)
    }
    
    /// Starts the analysis session (camera capture + pose detection + form analysis)
    func startAnalysis() {
        cameraPoseManager.startCapture()
        print("▶️ Analysis started")
    }
    
    /// Stops the analysis session and shows session summary
    func stopAnalysis() {
        cameraPoseManager.stopCapture()
        print("⏹️ Analysis stopped")
        
        // TODO: Show session summary (will be implemented by UI team)
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

extension CameraViewController: PoseDataDelegate {
    
    func didUpdatePoseData(_ data: PoseData) {
        // Store current pose data
        currentPoseData = data
        
        // === INTEGRATION: Developer A + Developer B ===
        
        // 1. Pass poseData to squatAnalyzer.analyzeSquat()
        let formResult = squatAnalyzer.analyzeSquat(poseData: data)
        currentFormResult = formResult
        
        // 2. Pass FormAnalysisResult to repCounter.updateWithAnalysis()
        repCounter.updateWithAnalysis(formResult)
        currentRepData = repCounter.getCurrentData()
        
        // 3. Print to console (only on state changes or every 1 second)
        let stateChanged = previousState != formResult.squatState
        let currentTime = Date()
        let shouldLogSummary = currentTime.timeIntervalSince(lastSummaryLogTime) >= summaryLogInterval
        
        if stateChanged {
            // Always log state changes immediately
            printAnalysisToConsole(formResult: formResult, repData: currentRepData!)
        } else if shouldLogSummary {
            // Periodic update every 1 second
            printAnalysisToConsole(formResult: formResult, repData: currentRepData!)
            lastSummaryLogTime = currentTime
        }
        previousState = formResult.squatState
        
        // 4. Update SkeletonRenderer color based on isGoodForm
        // Use smart side selection to filter visual data
        if let filteredVisualData = sideSelector.selectBestSide(from: data) {
            // Create filtered PoseData with only the selected side's joints
            let visualPoseData = createFilteredPoseData(from: filteredVisualData)
            
            let skeletonColor: UIColor = formResult.isGoodForm ? .systemGreen : .systemRed
            skeletonRenderer?.updateSkeleton(poseData: visualPoseData, color: skeletonColor)
        }
        
        // === Developer A's Visual Components ===
        
        // Update body detection state
        let bodyDetected = bodyDetectionManager.updateDetectionState(poseData: data)
        
        // Update positioning guide visibility
        let shouldShowGuide = bodyDetectionManager.shouldShowPositioningGuide()
        if shouldShowGuide {
            positioningGuideView.show(animated: true)
        } else {
            positioningGuideView.hide(animated: true)
        }
    }
    
    /// Create filtered PoseData with only selected side's joints
    private func createFilteredPoseData(from filtered: FilteredPoseData) -> PoseData {
        var jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        var confidences: [VNHumanBodyPoseObservation.JointName: Float] = [:]
        
        if filtered.side == .left {
            jointPositions[.leftShoulder] = filtered.shoulder
            jointPositions[.leftHip] = filtered.hip
            jointPositions[.leftKnee] = filtered.knee
            jointPositions[.leftAnkle] = filtered.ankle
            confidences[.leftShoulder] = filtered.shoulderConf
            confidences[.leftHip] = filtered.hipConf
            confidences[.leftKnee] = filtered.kneeConf
            confidences[.leftAnkle] = filtered.ankleConf
        } else {
            jointPositions[.rightShoulder] = filtered.shoulder
            jointPositions[.rightHip] = filtered.hip
            jointPositions[.rightKnee] = filtered.knee
            jointPositions[.rightAnkle] = filtered.ankle
            confidences[.rightShoulder] = filtered.shoulderConf
            confidences[.rightHip] = filtered.hipConf
            confidences[.rightKnee] = filtered.kneeConf
            confidences[.rightAnkle] = filtered.ankleConf
        }
        
        return PoseData(jointPositions: jointPositions, confidences: confidences)
    }
    
    /// Print form analysis results to console
    private func printAnalysisToConsole(formResult: FormAnalysisResult, repData: RepCountData) {
        // Format state
        let stateText: String
        switch formResult.squatState {
        case .standing: stateText = "Standing"
        case .descending: stateText = "Descending ⬇️"
        case .inSquat: stateText = "In Squat 🏋️"
        case .ascending: stateText = "Ascending ⬆️"
        }
        
        // Format form assessment
        let formText = formResult.isGoodForm ? "✅ GOOD" : "❌ BAD"
        
        // Format knee angle
        let kneeAngleText = formResult.kneeAngle.map { String(format: "%.1f°", $0) } ?? "N/A"
        
        // Format rep counts
        let repsText = "\(repData.totalReps) total (✅ \(repData.goodFormReps) good, ❌ \(repData.badFormReps) bad)"
        
        // Print comprehensive log
        print("""
        🎯 Form Analysis:
           State: \(stateText)
           Form: \(formText)
           Knee Angle: \(kneeAngleText)
           Issue: \(formResult.primaryIssue ?? "None")
           Reps: \(repsText)
        """)
    }
}
