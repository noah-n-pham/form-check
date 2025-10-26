//
//  CameraPoseManager.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation
import Vision

/// Complete camera and pose detection system
/// Handles camera setup, frame capture, and real-time pose detection
final class CameraPoseManager: NSObject {
    
    // MARK: - Properties
    
    /// Delegate to receive pose data updates
    weak var delegate: PoseDataDelegate?
    
    // MARK: - Camera Properties
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    // MARK: - Processing Queue
    
    private let videoDataOutputQueue = DispatchQueue(
        label: "com.formcheck.videoDataOutputQueue",
        qos: .userInitiated
    )
    
    // MARK: - Vision Request
    
    private lazy var poseDetectionRequest: VNDetectHumanBodyPoseRequest = {
        let request = VNDetectHumanBodyPoseRequest()
        return request
    }()
    
    // MARK: - Target Joint Keys
    
    private let targetJoints: [VNHumanBodyPoseObservation.JointName] = [
        .leftShoulder,
        .rightShoulder,
        .leftHip,
        .rightHip,
        .leftKnee,
        .rightKnee,
        .leftAnkle,
        .rightAnkle
    ]
    
    // MARK: - State
    
    private var isCapturing = false
    
    // MARK: - Public Methods
    
    /// Sets up the camera in the provided view
    /// - Parameters:
    ///   - containerView: The view to add the preview layer to
    ///   - completion: Called with success status and optional error message
    func setupCamera(in containerView: UIView, completion: @escaping (Bool, String?) -> Void) {
        // Check camera permission first
        checkCameraPermission { [weak self] granted in
            guard granted else {
                DispatchQueue.main.async {
                    completion(false, "Camera permission denied. Please enable in Settings.")
                }
                return
            }
            
            // Configure on main thread
            DispatchQueue.main.async {
                self?.configureCamera(in: containerView, completion: completion)
            }
        }
    }
    
    /// Starts the capture session
    func startCapture() {
        guard !isCapturing else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            self.isCapturing = true
        }
    }
    
    /// Stops the capture session
    func stopCapture() {
        guard isCapturing else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.stopRunning()
            self.isCapturing = false
        }
    }
    
    /// Gets the preview layer for external access
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    // MARK: - Camera Permission
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
            
        case .denied, .restricted:
            completion(false)
            
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Camera Configuration
    
    private func configureCamera(in containerView: UIView, completion: @escaping (Bool, String?) -> Void) {
        captureSession.beginConfiguration()
        
        // Set resolution to 1280x720
        if captureSession.canSetSessionPreset(.hd1280x720) {
            captureSession.sessionPreset = .hd1280x720
        } else {
            captureSession.sessionPreset = .high
        }
        
        // Get front camera
        guard let frontCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            captureSession.commitConfiguration()
            completion(false, "Front camera not available")
            return
        }
        
        // Add camera input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            guard captureSession.canAddInput(cameraInput) else {
                captureSession.commitConfiguration()
                completion(false, "Cannot add camera input")
                return
            }
            
            captureSession.addInput(cameraInput)
            
            // Configure frame rate to 15 FPS
            try configureCameraFrameRate(camera: frontCamera, targetFPS: FormCheckConstants.TARGET_FPS)
            
        } catch {
            captureSession.commitConfiguration()
            completion(false, "Failed to create camera input: \(error.localizedDescription)")
            return
        }
        
        // Setup video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        guard captureSession.canAddOutput(videoOutput) else {
            captureSession.commitConfiguration()
            completion(false, "Cannot add video output")
            return
        }
        
        captureSession.addOutput(videoOutput)
        self.videoOutput = videoOutput
        
        captureSession.commitConfiguration()
        
        // Setup preview layer
        setupPreviewLayer(in: containerView)
        
        completion(true, nil)
    }
    
    private func configureCameraFrameRate(camera: AVCaptureDevice, targetFPS: Int) throws {
        try camera.lockForConfiguration()
        
        // Find format that supports target frame rate
        for range in camera.activeFormat.videoSupportedFrameRateRanges {
            let fps = Double(targetFPS)
            if range.minFrameRate <= fps && fps <= range.maxFrameRate {
                camera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(targetFPS))
                camera.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(targetFPS))
                break
            }
        }
        
        camera.unlockForConfiguration()
    }
    
    private func setupPreviewLayer(in containerView: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = containerView.bounds
        
        containerView.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
    
    // MARK: - Pose Detection
    
    private func detectPose(in pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .up,
            options: [:]
        )
        
        do {
            try handler.perform([poseDetectionRequest])
            
            guard let observation = poseDetectionRequest.results?.first else {
                return
            }
            
            processPoseObservation(observation)
            
        } catch {
            print("❌ Pose detection failed: \(error.localizedDescription)")
        }
    }
    
    private func processPoseObservation(_ observation: VNHumanBodyPoseObservation) {
        var jointPositions: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        var confidences: [VNHumanBodyPoseObservation.JointName: Float] = [:]
        
        // Extract target joints
        for jointKey in targetJoints {
            guard let recognizedPoint = try? observation.recognizedPoint(jointKey) else {
                // Joint not detected, skip
                continue
            }
            
            // Filter by confidence threshold
            if recognizedPoint.confidence >= FormCheckConstants.CONFIDENCE_THRESHOLD {
                // Convert normalized coordinates to screen coordinates
                let screenPoint = convertVisionPointToScreen(recognizedPoint.location)
                
                jointPositions[jointKey] = screenPoint
                confidences[jointKey] = recognizedPoint.confidence
            }
        }
        
        // Only send pose data if we have at least some joints
        guard !jointPositions.isEmpty else {
            return
        }
        
        // Create PoseData and notify delegate
        let poseData = PoseData(
            jointPositions: jointPositions,
            confidences: confidences
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didUpdatePoseData(poseData)
        }
    }
    
    // MARK: - Coordinate Conversion
    
    /// Converts Vision framework normalized coordinates (0-1, origin bottom-left)
    /// to screen pixel coordinates matching the preview layer
    private func convertVisionPointToScreen(_ visionPoint: CGPoint) -> CGPoint {
        guard let previewLayer = previewLayer else {
            return .zero
        }
        
        // Vision coordinates: (0,0) is bottom-left, (1,1) is top-right
        // Need to convert to UIKit coordinates: (0,0) is top-left
        
        // Flip Y coordinate (Vision has origin at bottom-left)
        let flippedY = 1.0 - visionPoint.y
        
        // Get preview layer bounds
        let layerWidth = previewLayer.bounds.width
        let layerHeight = previewLayer.bounds.height
        
        // Convert to screen coordinates
        // Vision coordinates are normalized (0-1), so multiply by screen dimensions
        let screenX = visionPoint.x * layerWidth
        let screenY = flippedY * layerHeight
        
        return CGPoint(x: screenX, y: screenY)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraPoseManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Extract pixel buffer from sample buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Perform pose detection
        detectPose(in: pixelBuffer)
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didDrop sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Frame was dropped due to processing backlog
        // This is normal and helps maintain performance
    }
}

