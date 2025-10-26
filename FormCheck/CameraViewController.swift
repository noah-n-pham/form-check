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
    private let formQualityTracker = FormQualityTracker()
    private let sideSelector = SideSelector()
    
    // MARK: - Visual Components (Developer A)
    
    private var skeletonRenderer: SkeletonRenderer?
    private let bodyDetectionManager = BodyDetectionManager()
    
    private let positioningGuideView: PositioningGuideView = {
        let view = PositioningGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Form Quality UI
    
    private let formQualityLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 72, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "—"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 4
        return label
    }()
    
    private let coachingCuesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 4
        return label
    }()
    
    private let repCountContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let repCountLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let repsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "REPS"
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - State Tracking
    
    /// Previous squat state for detecting state changes
    private var previousState: SquatState?
    
    /// Previous rep count for detecting rep completion
    private var previousRepCount: Int = 0
    
    /// Throttle console logging
    private var lastSummaryLogTime: Date = Date()
    private let summaryLogInterval: TimeInterval = 1.0  // Log summary every 1 second
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Squat Analysis"
        
        // Configure navigation bar with back button
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
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
        
        // Add form quality rating label (center)
        view.addSubview(formQualityLabel)
        NSLayoutConstraint.activate([
            formQualityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formQualityLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        formQualityLabel.alpha = 0  // Hidden until rep completes
        
        // Add coaching cues label (below center)
        view.addSubview(coachingCuesLabel)
        NSLayoutConstraint.activate([
            coachingCuesLabel.topAnchor.constraint(equalTo: formQualityLabel.bottomAnchor, constant: 20),
            coachingCuesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            coachingCuesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        coachingCuesLabel.alpha = 0  // Hidden until rep completes
        
        // Add rep count container (top right)
        view.addSubview(repCountContainerView)
        repCountContainerView.addSubview(repCountLabel)
        repCountContainerView.addSubview(repsTitleLabel)
        
        NSLayoutConstraint.activate([
            // Container
            repCountContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            repCountContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            repCountContainerView.widthAnchor.constraint(equalToConstant: 80),
            repCountContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Rep count number
            repCountLabel.centerXAnchor.constraint(equalTo: repCountContainerView.centerXAnchor),
            repCountLabel.topAnchor.constraint(equalTo: repCountContainerView.topAnchor, constant: 8),
            
            // "REPS" title
            repsTitleLabel.centerXAnchor.constraint(equalTo: repCountContainerView.centerXAnchor),
            repsTitleLabel.topAnchor.constraint(equalTo: repCountLabel.bottomAnchor, constant: 2)
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
        
        // Store previous state for rep completion detection
        let wasAscending = previousState == .ascending
        previousState = formResult.squatState
        
        // 2. Pass FormAnalysisResult to formQualityTracker.updateWithAnalysis()
        formQualityTracker.updateWithAnalysis(formResult)
        currentRepData = formQualityTracker.getCurrentData()
        
        // 3. Update UI with live data
        updateUI(formResult: formResult, repData: currentRepData!)
        
        // 4. Show rep completion feedback
        if wasAscending && formResult.squatState == .standing {
            showRepCompletionFeedback(repData: currentRepData!)
        }
        
        // 4. Update SkeletonRenderer color based on isGoodForm
        // Use side locking (pass squat state) to prevent mid-rep switching
        if let filteredVisualData = sideSelector.selectBestSide(from: data, squatState: formResult.squatState) {
            // Create filtered PoseData with only the selected side's joints
            let visualPoseData = createFilteredPoseData(from: filteredVisualData)
            
            let skeletonColor: UIColor = formResult.isGoodForm ? .systemGreen : .systemRed
            skeletonRenderer?.updateSkeleton(poseData: visualPoseData, color: skeletonColor)
        } else {
            // Both sides have poor quality - show all available joints anyway (better than freezing)
            let skeletonColor: UIColor = formResult.isGoodForm ? .systemGreen : .systemRed
            skeletonRenderer?.updateSkeleton(poseData: data, color: skeletonColor)
        }
        
        // === Developer A's Visual Components ===
        
        // Update body detection state (use raw data for detection logic)
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
    
    // MARK: - UI Updates
    
    private func updateUI(formResult: FormAnalysisResult, repData: RepCountData) {
        // Check if rep count changed
        if repData.totalReps != previousRepCount {
            animateRepCountUpdate(newCount: repData.totalReps, quality: repData.lastRepQuality)
            previousRepCount = repData.totalReps
        }
    }
    
    private func animateRepCountUpdate(newCount: Int, quality: Int?) {
        // Update the text
        repCountLabel.text = "\(newCount)"
        
        // Determine color based on quality
        var pulseColor: UIColor = .systemBlue
        if let quality = quality {
            if quality >= 85 {
                pulseColor = .systemGreen
            } else if quality >= 70 {
                pulseColor = .systemYellow
            } else {
                pulseColor = .systemRed
            }
        }
        
        // Generate haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Spring animation for the container
        repCountContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Flash color effect
        let originalBackgroundColor = repCountContainerView.backgroundColor
        repCountContainerView.backgroundColor = pulseColor.withAlphaComponent(0.4)
        
        // Animate with spring effect
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: [.curveEaseOut]) {
            self.repCountContainerView.transform = .identity
        }
        
        // Fade back to original background color
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [.curveEaseInOut]) {
            self.repCountContainerView.backgroundColor = originalBackgroundColor
        }
        
        // Scale animation for the label itself
        repCountLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, delay: 0.05, options: [.curveEaseOut]) {
            self.repCountLabel.transform = .identity
        }
    }
    
    private func showRepCompletionFeedback(repData: RepCountData) {
        guard let quality = repData.lastRepQuality else { return }
        
        // Set quality score
        formQualityLabel.text = "\(quality)"
        
        // Color code based on quality
        if quality >= 85 {
            formQualityLabel.textColor = .systemGreen
        } else if quality >= 70 {
            formQualityLabel.textColor = .systemYellow
        } else {
            formQualityLabel.textColor = .systemRed
        }
        
        // Set coaching cues
        if repData.lastRepCues.isEmpty {
            coachingCuesLabel.text = ""
            coachingCuesLabel.alpha = 0
        } else {
            coachingCuesLabel.text = repData.lastRepCues.joined(separator: "\n")
            coachingCuesLabel.alpha = 1
        }
        
        // Animate in
        formQualityLabel.alpha = 1
        formQualityLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.formQualityLabel.transform = .identity
        })
        
        // Animate out after 2.5 seconds
        UIView.animate(withDuration: 0.5, delay: 2.5, options: [], animations: {
            self.formQualityLabel.alpha = 0
            self.coachingCuesLabel.alpha = 0
        })
    }
}
