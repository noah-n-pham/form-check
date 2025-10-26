//
//  FeedbackTestViewController.swift
//  FormCheck
//
//  Created for GatorHack
//  Test harness for feedback system
//

import UIKit
import AVFoundation

class FeedbackTestViewController: UIViewController {
    
    // MARK: - Properties
    
    var overlayManager: FeedbackOverlayManager?
    var audioManager: AudioFeedbackManager?
    var angleViz: AngleVisualizer? // trying abbreviated names
    var summaryPresenter = SessionSummaryPresenter()
    
    // Rep tracking
    var totalReps: Int = 0
    var goodReps = 0
    var badReps = 0
    var lifetimeReps: Int = 245 // hard-coded for testing
    
    // MARK: - UI Components
    
    let cameraSimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray3 // lighter gray to match figma preview
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let buttonPanel: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6 // compact spacing to show more of the overlays
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alpha = 0.9 // slightly transparent so we can see through
        return stack
    }()
    
    // Red record button like in figma design
    let recordButton: UIView = {
        let btn = UIView()
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 35 // 70/2 for circular shape
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🧪 TestViewController loaded")
        
        setupUI()
        setupFeedbackSystem()
        setupButtons()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = .black
        title = "Feedback Test"
        
        view.addSubview(cameraSimView)
        view.addSubview(recordButton)
        view.addSubview(buttonPanel)
        
        // Layout
        NSLayoutConstraint.activate([
            cameraSimView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraSimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraSimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraSimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Red record button at bottom-right like figma design
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            buttonPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonPanel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupFeedbackSystem() {
        // Initialize feedback manager
        let previewBounds = view.bounds
        overlayManager = FeedbackOverlayManager(parentView: cameraSimView, previewLayerBounds: previewBounds)
        
        // Audio manager
        audioManager = AudioFeedbackManager()
        
        // Angle visualizer - need a dummy preview layer
        let dummyLayer = AVCaptureVideoPreviewLayer()
        dummyLayer.frame = cameraSimView.bounds
        angleViz = AngleVisualizer(previewLayer: dummyLayer, containerView: cameraSimView)
        
        print("✅ Feedback system initialized")
    }
    
    func setupButtons() {
        // Form issue buttons
        let goodFormBtn = createButton(title: "Good Form Squat", color: .systemGreen)
        goodFormBtn.addTarget(self, action: #selector(testGoodForm), for: .touchUpInside)
        
        let kneesForwardBtn = createButton(title: "Knees Too Forward", color: .systemOrange)
        kneesForwardBtn.addTarget(self, action: #selector(testKneesForward), for: .touchUpInside)
        
        let notDeepBtn = createButton(title: "Not Deep Enough", color: .systemOrange)
        notDeepBtn.addTarget(self, action: #selector(testNotDeep), for: .touchUpInside)
        
        let backAngleBtn = createButton(title: "Back Angle Issue", color: .systemOrange)
        backAngleBtn.addTarget(self, action: #selector(testBackAngle), for: .touchUpInside)
        
        // Rep completion buttons
        let completeGoodBtn = createButton(title: "Complete Rep (Good)", color: .systemBlue)
        completeGoodBtn.addTarget(self, action: #selector(completeGoodRep), for: .touchUpInside)
        
        let completeBadBtn = createButton(title: "Complete Rep (Bad)", color: .systemRed)
        completeBadBtn.addTarget(self, action: #selector(completeBadRep), for: .touchUpInside)
        
        // Summary button
        let summaryBtn = createButton(title: "Show Summary", color: .systemPurple)
        summaryBtn.addTarget(self, action: #selector(showSummary), for: .touchUpInside)
        
        // Reset button
        let resetBtn = createButton(title: "Reset Counters", color: .systemGray)
        resetBtn.addTarget(self, action: #selector(resetCounters), for: .touchUpInside)
        
        // Add to stack
        buttonPanel.addArrangedSubview(goodFormBtn)
        buttonPanel.addArrangedSubview(kneesForwardBtn)
        buttonPanel.addArrangedSubview(notDeepBtn)
        buttonPanel.addArrangedSubview(backAngleBtn)
        buttonPanel.addArrangedSubview(completeGoodBtn)
        buttonPanel.addArrangedSubview(completeBadBtn)
        buttonPanel.addArrangedSubview(summaryBtn)
        buttonPanel.addArrangedSubview(resetBtn)
    }
    
    func createButton(title: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = color.withAlphaComponent(0.35) // slightly more visible
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold) // smaller font
        btn.layer.cornerRadius = 10 // match overlay corner radius
        btn.heightAnchor.constraint(equalToConstant: 38).isActive = true // more compact
        return btn
    }
    
    // MARK: - Test Actions
    
    @objc func testGoodForm() {
        print("🟢 Testing good form")
        overlayManager?.updateTextFeedback(message: "Great form! Keep it up! ✅")
        
        // Show angle indicator with good angle (85 degrees)
        let centerPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        let startPt = CGPoint(x: centerPoint.x - 40, y: centerPoint.y - 40)
        let endPt = CGPoint(x: centerPoint.x + 40, y: centerPoint.y + 40)
        
        angleViz?.showAngleIndicator(at: centerPoint, angle: 85, isGoodForm: true, vectorStart: startPt, vectorEnd: endPt)
        
        // Hide angle after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.angleViz?.hideAngleIndicator()
        }
    }
    
    @objc func testKneesForward() {
        print("⚠️ Testing knees forward")
        overlayManager?.updateTextFeedback(message: "⚠️ Knees too far forward")
        
        // Play audio alert - this approach works better
        audioManager?.playFormWarning()
        
        // Show bad angle (60 degrees - too acute)
        let centerPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        let startPt: CGPoint = CGPoint(x: centerPoint.x - 30, y: centerPoint.y - 30)
        let endPt: CGPoint = CGPoint(x: centerPoint.x + 50, y: centerPoint.y + 20)
        
        angleViz?.showAngleIndicator(at: centerPoint, angle: 60, isGoodForm: false, vectorStart: startPt, vectorEnd: endPt)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.angleViz?.hideAngleIndicator()
        }
    }
    
    @objc func testNotDeep() {
        print("⚠️ Testing not deep enough")
        overlayManager?.updateTextFeedback(message: "⚠️ Go deeper in your squat")
        audioManager!.playFormWarning() // we know it exists
        
        // Show angle (120 degrees - not deep enough)
        let centerPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        angleViz?.showAngleIndicator(
            at: centerPoint,
            angle: 120,
            isGoodForm: false,
            vectorStart: CGPoint(x: centerPoint.x - 50, y: centerPoint.y),
            vectorEnd: CGPoint(x: centerPoint.x + 30, y: centerPoint.y + 50)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.angleViz?.hideAngleIndicator()
        }
    }
    
    @objc func testBackAngle() {
        print("⚠️ Testing back angle issue")
        overlayManager?.updateTextFeedback(message: "⚠️ Keep your back straighter")
        audioManager?.playFormWarning()
        
        // TODO: add back angle visualization with different position
        let testPoint = CGPoint(x: view.bounds.width * 0.6, y: view.bounds.height * 0.4)
        angleViz?.showAngleIndicator(
            at: testPoint,
            angle: 45,
            isGoodForm: false,
            vectorStart: CGPoint(x: testPoint.x - 40, y: testPoint.y + 10),
            vectorEnd: CGPoint(x: testPoint.x + 20, y: testPoint.y - 40)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.angleViz?.hideAngleIndicator()
        }
    }
    
    @objc func completeGoodRep() {
        totalReps += 1
        goodReps += 1
        lifetimeReps += 1
        
        print("✅ Good rep completed! Total: \(totalReps)")
        
        updateCounters()
        overlayManager?.updateTextFeedback(message: "Perfect rep! ✅")
        
        // FIXME: maybe add success sound here later
    }
    
    @objc func completeBadRep() {
        totalReps += 1
        badReps += 1
        lifetimeReps += 1 // still counts toward lifetime
        
        print("❌ Bad rep completed. Total: \(totalReps)")
        
        updateCounters()
        overlayManager?.updateTextFeedback(message: "Rep completed - watch your form")
        audioManager?.playFormWarning()
    }
    
    @objc func showSummary() {
        print("📊 Showing summary")
        
        // Calculate percentage
        var percentage: Double = 0.0
        if totalReps > 0 {
            percentage = (Double(goodReps) / Double(totalReps)) * 100.0
        }
        
        // Create session summary
        let summary = SessionSummary(
            totalReps: totalReps,
            goodFormPercentage: percentage,
            mostCommonIssue: badReps > 0 ? "Knees tracking forward" : nil
        )
        
        summaryPresenter.showSummary(
            sessionData: summary,
            lifetimeReps: lifetimeReps,
            onContinue: {
                print("Continue pressed")
                // Just dismiss and continue
            },
            onEnd: {
                print("End pressed")
                // Navigate back
                self.navigationController?.popViewController(animated: true)
            },
            presentingViewController: self
        )
    }
    
    @objc func resetCounters() {
        print("🔄 Resetting counters")
        
        totalReps = 0
        goodReps = 0
        badReps = 0
        
        updateCounters()
        overlayManager?.updateTextFeedback(message: "Counters reset - ready to test")
        audioManager?.reset()
        
        // not sure why this works but it does - re-prepare the overlay
        overlayManager?.reset()
    }
    
    // MARK: - Helper Methods
    
    func updateCounters() {
        // trying this approach
        let repData = RepCountData(
            totalReps: totalReps,
            goodFormReps: goodReps,
            badFormReps: badReps
        )
        
        overlayManager?.updateRepCounters(data: repData)
    }
}

