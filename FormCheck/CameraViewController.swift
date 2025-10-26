//
//  CameraViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation

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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Squat Analysis"
        
        // Set up camera manager delegate
        cameraPoseManager.delegate = self
        
        // Setup camera
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    // MARK: - Method Signatures (Contract Definition)
    
    /// Sets up the camera capture session and preview layer
    func setupCamera() {
        cameraPoseManager.setupCamera(in: view) { [weak self] success, errorMessage in
            if success {
                print("✅ Camera setup successful")
            } else {
                print("❌ Camera setup failed: \(errorMessage ?? "Unknown error")")
                self?.showCameraError(errorMessage ?? "Failed to setup camera")
            }
        }
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
        
        // Debug: Print detected joints
        print("🦴 Detected \(data.jointPositions.count) joints with confidence >= \(FormCheckConstants.CONFIDENCE_THRESHOLD)")
        
        // TODO: Pass to form analysis (will be implemented by form analysis team)
        // TODO: Update visual overlays (will be implemented by UI team)
    }
}
