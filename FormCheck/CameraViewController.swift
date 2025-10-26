import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    // MARK: - Capture Session Properties
    private let captureSession = AVCaptureSession()
    private var frontCamera: AVCaptureDevice?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Frame Processing
    private let videoDataOutputQueue = DispatchQueue(label: "com.formcheck.videoDataOutputQueue", qos: .userInitiated)
    private var lastFrameTimestamp: CMTime = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Camera"
        navigationItem.backButtonTitle = "Back"
        
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        // Request camera permission
        requestCameraPermission { [weak self] granted in
            guard granted else {
                print("Camera permission denied")
                return
            }
            
            DispatchQueue.main.async {
                self?.configureCaptureSession()
            }
        }
    }
    
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
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
    
    private func configureCaptureSession() {
        captureSession.beginConfiguration()
        
        // Set session preset to 1280x720
        if captureSession.canSetSessionPreset(.hd1280x720) {
            captureSession.sessionPreset = .hd1280x720
        } else {
            captureSession.sessionPreset = .high
        }
        
        // Setup front camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Front camera not available")
            captureSession.commitConfiguration()
            return
        }
        
        self.frontCamera = frontCamera
        
        do {
            // Create camera input
            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            guard let frontCameraInput = frontCameraInput,
                  captureSession.canAddInput(frontCameraInput) else {
                print("Cannot add camera input")
                captureSession.commitConfiguration()
                return
            }
            
            captureSession.addInput(frontCameraInput)
            
            // Configure camera for 15 FPS
            try configureCameraFrameRate(camera: frontCamera, desiredFrameRate: 15)
            
            // Setup video output
            videoOutput = AVCaptureVideoDataOutput()
            guard let videoOutput = videoOutput else {
                captureSession.commitConfiguration()
                return
            }
            
            // Configure video output settings
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
        } catch {
            print("Error setting up camera input: \(error)")
        }
        
        captureSession.commitConfiguration()
        
        // Setup preview layer after session configuration
        setupPreviewLayer()
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        guard let previewLayer = previewLayer else { return }
        view.layer.addSublayer(previewLayer)
    }
    
    // MARK: - Session Control
    func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    // MARK: - Camera Configuration
    private func configureCameraFrameRate(camera: AVCaptureDevice, desiredFrameRate: Int32) throws {
        try camera.lockForConfiguration()
        
        // Find format that supports desired frame rate
        for range in camera.activeFormat.videoSupportedFrameRateRanges {
            if range.minFrameRate <= Double(desiredFrameRate) && Double(desiredFrameRate) <= range.maxFrameRate {
                camera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: desiredFrameRate)
                camera.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: desiredFrameRate)
                print("✅ Camera configured for \(desiredFrameRate) FPS")
                break
            }
        }
        
        camera.unlockForConfiguration()
    }
    
    // MARK: - Frame Processing
    private func processVideoFrame(sampleBuffer: CMSampleBuffer) {
        // Extract CVPixelBuffer from CMSampleBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("❌ Failed to get pixel buffer from sample buffer")
            return
        }
        
        // Get timestamp
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        // Calculate frame rate
        if lastFrameTimestamp != .zero {
            let timeDifference = CMTimeGetSeconds(timestamp) - CMTimeGetSeconds(lastFrameTimestamp)
            let currentFPS = 1.0 / timeDifference
            print("📹 Frame captured at timestamp: \(CMTimeGetSeconds(timestamp))s | FPS: \(String(format: "%.2f", currentFPS))")
        } else {
            print("📹 First frame captured at timestamp: \(CMTimeGetSeconds(timestamp))s")
        }
        
        lastFrameTimestamp = timestamp
        
        // Pixel buffer is now available for further processing
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        print("📐 Frame dimensions: \(width)x\(height)")
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        processVideoFrame(sampleBuffer: sampleBuffer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("⚠️ Frame dropped")
    }
}
