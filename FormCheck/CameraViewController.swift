//
//  CameraViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation

/// Main camera view controller for squat analysis
/// This is an empty shell with contracts - implementation will be filled in later
final class CameraViewController: UIViewController {
    
    // MARK: - Properties (Contract Definition)
    
    /// Preview layer for displaying camera feed
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Current pose data from Vision framework
    var currentPoseData: PoseData?
    
    /// Current form analysis result
    var currentFormResult: FormAnalysisResult?
    
    /// Current rep count data
    var currentRepData: RepCountData?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Squat Analysis"
        
        // Setup will be implemented later
        setupCamera()
    }
    
    // MARK: - Method Signatures (Contract Definition)
    
    /// Sets up the camera capture session and preview layer
    /// To be implemented: Configure AVCaptureSession, add preview layer, request permissions
    func setupCamera() {
        // TODO: Implementation by camera team
    }
    
    /// Adds an overlay component (e.g., skeleton view, feedback label) to the camera view
    /// - Parameter view: The UIView to add as an overlay
    func addOverlayComponent(_ view: UIView) {
        // TODO: Implementation by UI team
    }
    
    /// Starts the analysis session (camera capture + pose detection + form analysis)
    func startAnalysis() {
        // TODO: Implementation by integration team
    }
    
    /// Stops the analysis session and shows session summary
    func stopAnalysis() {
        // TODO: Implementation by integration team
    }
}
