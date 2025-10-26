import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    // MARK: - Capture Session Properties
    private let captureSession = AVCaptureSession()
    private var frontCamera: AVCaptureDevice?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Camera will appear here"
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Camera"

        // Placeholder UI
        view.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

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
            
            // Setup video output
            videoOutput = AVCaptureVideoDataOutput()
            guard let videoOutput = videoOutput else {
                captureSession.commitConfiguration()
                return
            }
            
            videoOutput.setSampleBufferDelegate(nil, queue: DispatchQueue.global(qos: .userInitiated))
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
        } catch {
            print("Error setting up camera input: \(error)")
        }
        
        captureSession.commitConfiguration()
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
}
