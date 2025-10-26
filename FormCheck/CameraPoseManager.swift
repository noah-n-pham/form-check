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
        // Head
        .nose,
        
        // Shoulders
        .leftShoulder,
        .rightShoulder,
        
        // Arms
        .leftElbow,
        .rightElbow,
        .leftWrist,
        .rightWrist,
        
        // Torso
        .leftHip,
        .rightHip,
        
        // Legs
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
        
        // Set video orientation to match device orientation
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            // Mirror the video for front camera (more natural for user)
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
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
        // Use .left orientation for front camera in portrait mode with mirrored preview
        // This tells Vision the correct orientation of the captured image
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .left,
            options: [:]
        )
        
        do {
            try handler.perform([poseDetectionRequest])
            
            if let observation = poseDetectionRequest.results?.first {
                // Body detected by Vision, process it
                processPoseObservation(observation)
            } else {
                // No body detected at all - send empty pose data for real-time UI updates
                sendEmptyPoseData()
            }
            
        } catch {
            print("❌ Pose detection failed: \(error.localizedDescription)")
            // Send empty data on error too, so UI can update
            sendEmptyPoseData()
        }
    }
    
    private func sendEmptyPoseData() {
        let emptyPoseData = PoseData(
            jointPositions: [:],
            confidences: [:]
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didUpdatePoseData(emptyPoseData)
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
        
        // Always create and send PoseData, even if empty
        // This ensures real-time updates when user moves out of frame
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
        // With .right orientation, Vision already accounts for camera rotation
        // Just pass the coordinates directly - layerPointConverted handles the rest
        let captureDevicePoint = visionPoint
        
        // Use AVCaptureVideoPreviewLayer's built-in conversion
        // This properly handles video gravity, orientation, and aspect ratio
        let screenPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: captureDevicePoint)
        
        return screenPoint
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

