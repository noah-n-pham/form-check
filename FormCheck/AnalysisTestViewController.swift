//
//  AnalysisTestViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Test view controller for testing form analysis with mock data
final class AnalysisTestViewController: UIViewController {
    
    // MARK: - Components
    
    private let mockDataGenerator = MockPoseDataGenerator()
    private let squatAnalyzer = SquatAnalyzer()
    private let repCounter = RepCounter()
    
    // MARK: - Timer
    
    private var timer: Timer?
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Form Analysis Test"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Test", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stateLabel: UILabel = {
        let label = UILabel()
        label.text = "State: Standing"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let kneeAngleLabel: UILabel = {
        let label = UILabel()
        label.text = "Knee Angle: N/A"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formLabel: UILabel = {
        let label = UILabel()
        label.text = "Form: Good"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let issueLabel: UILabel = {
        let label = UILabel()
        label.text = "Issue: None"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let repsLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Reps: 0"
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goodRepsLabel: UILabel = {
        let label = UILabel()
        label.text = "Good Form: 0"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badRepsLabel: UILabel = {
        let label = UILabel()
        label.text = "Bad Form: 0"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formModeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Good Form", "Bad Form"])
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTest()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        title = "Analysis Test"
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(formModeSegment)
        view.addSubview(startButton)
        view.addSubview(stateLabel)
        view.addSubview(kneeAngleLabel)
        view.addSubview(formLabel)
        view.addSubview(issueLabel)
        view.addSubview(repsLabel)
        view.addSubview(goodRepsLabel)
        view.addSubview(badRepsLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            formModeSegment.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            formModeSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formModeSegment.widthAnchor.constraint(equalToConstant: 280),
            
            startButton.topAnchor.constraint(equalTo: formModeSegment.bottomAnchor, constant: 20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            stateLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 40),
            stateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            kneeAngleLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 15),
            kneeAngleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            formLabel.topAnchor.constraint(equalTo: kneeAngleLabel.bottomAnchor, constant: 15),
            formLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            issueLabel.topAnchor.constraint(equalTo: formLabel.bottomAnchor, constant: 15),
            issueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            issueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            repsLabel.topAnchor.constraint(equalTo: issueLabel.bottomAnchor, constant: 40),
            repsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            goodRepsLabel.topAnchor.constraint(equalTo: repsLabel.bottomAnchor, constant: 15),
            goodRepsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            badRepsLabel.topAnchor.constraint(equalTo: goodRepsLabel.bottomAnchor, constant: 10),
            badRepsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        formModeSegment.addTarget(self, action: #selector(formModeChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        if timer == nil {
            // Start test
            startButton.setTitle("Stop Test", for: .normal)
            startButton.backgroundColor = .systemRed
            mockDataGenerator.reset()
            squatAnalyzer.reset()
            repCounter.reset()
            
            // Run at 15 FPS
            timer = Timer.scheduledTimer(withTimeInterval: 1.0/15.0, repeats: true) { [weak self] _ in
                self?.processFrame()
            }
        } else {
            // Stop test
            stopTest()
        }
    }
    
    @objc private func formModeChanged() {
        let isGoodForm = formModeSegment.selectedSegmentIndex == 0
        mockDataGenerator.setGenerateGoodForm(isGoodForm)
    }
    
    private func stopTest() {
        timer?.invalidate()
        timer = nil
        startButton.setTitle("Start Test", for: .normal)
        startButton.backgroundColor = .systemBlue
    }
    
    // MARK: - Processing
    
    private func processFrame() {
        // Generate mock pose data
        let poseData = mockDataGenerator.generateNextFrame()
        
        // Analyze squat
        let result = squatAnalyzer.analyzeSquat(poseData: poseData)
        
        // Update rep counter
        repCounter.updateWithAnalysis(result)
        
        // Update UI
        updateUI(with: result)
    }
    
    private func updateUI(with result: FormAnalysisResult) {
        // Update state
        let stateText: String
        switch result.squatState {
        case .standing: stateText = "Standing"
        case .descending: stateText = "Descending"
        case .inSquat: stateText = "In Squat"
        case .ascending: stateText = "Ascending"
        }
        stateLabel.text = "State: \(stateText)"
        
        // Update knee angle
        if let angle = result.kneeAngle {
            kneeAngleLabel.text = String(format: "Knee Angle: %.1f°", angle)
        } else {
            kneeAngleLabel.text = "Knee Angle: N/A"
        }
        
        // Update form quality rating
        if result.formQuality >= 85 {
            formLabel.text = "Quality: \(result.formQuality) ✓"
            formLabel.textColor = .systemGreen
        } else if result.formQuality >= 70 {
            formLabel.text = "Quality: \(result.formQuality) ⚠️"
            formLabel.textColor = .systemYellow
        } else {
            formLabel.text = "Quality: \(result.formQuality) ✗"
            formLabel.textColor = .systemRed
        }
        
        // Update coaching cues
        if result.coachingCues.isEmpty {
            issueLabel.text = "Cues: None"
        } else {
            issueLabel.text = "Cues: \(result.coachingCues.joined(separator: ", "))"
        }
        
        // Update rep counts
        let repData = repCounter.getCurrentData()
        repsLabel.text = "Total Reps: \(repData.totalReps)"
        goodRepsLabel.text = "Avg Quality: \(repData.averageFormQuality)"
        badRepsLabel.text = "Last Rep: \(repData.lastRepQuality ?? 0)"
    }
}

