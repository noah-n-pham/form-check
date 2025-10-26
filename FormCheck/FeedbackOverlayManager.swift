//
//  FeedbackOverlayManager.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation

/// Manages all UI overlay components for the camera view
/// Provides real-time feedback and rep counting display
final class FeedbackOverlayManager {
    
    // MARK: - UI Components
    
    /// Container view with semi-transparent dark background for feedback text
    private let topFeedbackContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45) // adjusted for better readability
        view.layer.cornerRadius = 10 // slightly more rounded like figma
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Label for displaying form feedback messages
    private let topFeedbackLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Container for rep counter stack with semi-transparent background
    private let repCounterContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45) // matched with top container
        view.layer.cornerRadius = 10 // matched with top container
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Horizontal stack view displaying rep counters
    private let repCounterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    /// Label showing total reps
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Total: 0"
        return label
    }()
    
    /// Label showing good form reps
    private let goodLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Good: 0"
        return label
    }()
    
    /// Label showing bad form reps
    private let badLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Bad: 0"
        return label
    }()
    
    /// Separator views for visual distinction
    private let separator1: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "|"
        return label
    }()
    
    private let separator2: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "|"
        return label
    }()
    
    // MARK: - Gradient Overlays
    
    /// Top gradient layer for improved text readability
    private var topGradientLayer: CAGradientLayer?
    
    /// Bottom gradient layer for improved text readability
    private var bottomGradientLayer: CAGradientLayer?
    
    // MARK: - Properties
    
    /// Reference to the parent view (camera view)
    private weak var parentView: UIView?
    
    /// Preview layer bounds for layout calculations
    private let previewBounds: CGRect
    
    /// Last total count to detect changes for animation
    private var lastTotalCount: Int = 0
    
    // MARK: - Initialization
    
    /// Initializes the feedback overlay manager
    /// - Parameters:
    ///   - parentView: The parent view to add overlays to (typically camera view)
    ///   - previewLayerBounds: Bounds of the preview layer for layout
    init(parentView: UIView, previewLayerBounds: CGRect) {
        self.parentView = parentView
        self.previewBounds = previewLayerBounds
        setupOverlays()
    }
    
    // MARK: - Setup
    
    /// Sets up all overlay components and adds them to the parent view
    private func setupOverlays() {
        guard let parentView = parentView else { return }
        
        // Setup gradient overlays first (as bottom-most layers)
        setupGradientOverlays()
        
        // Setup top feedback container and label
        setupTopFeedback(in: parentView)
        
        // Setup rep counter stack
        setupRepCounter(in: parentView)
    }
    
    /// Sets up the top feedback label container
    private func setupTopFeedback(in parentView: UIView) {
        // Add container to parent view
        parentView.addSubview(topFeedbackContainer)
        
        // Add label to container
        topFeedbackContainer.addSubview(topFeedbackLabel)
        
        // Layout constraints for container - adjusted to match figma
        NSLayoutConstraint.activate([
            topFeedbackContainer.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 12),
            topFeedbackContainer.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            topFeedbackContainer.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            topFeedbackContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Layout constraints for label (inset within container)
        NSLayoutConstraint.activate([
            topFeedbackLabel.topAnchor.constraint(equalTo: topFeedbackContainer.topAnchor, constant: 8),
            topFeedbackLabel.bottomAnchor.constraint(equalTo: topFeedbackContainer.bottomAnchor, constant: -8),
            topFeedbackLabel.leadingAnchor.constraint(equalTo: topFeedbackContainer.leadingAnchor, constant: 16),
            topFeedbackLabel.trailingAnchor.constraint(equalTo: topFeedbackContainer.trailingAnchor, constant: -16)
        ])
        
        // Set initial message
        topFeedbackLabel.text = "Ready to analyze your form"
    }
    
    /// Sets up the rep counter stack at the bottom
    private func setupRepCounter(in parentView: UIView) {
        // Add container to parent view
        parentView.addSubview(repCounterContainer)
        
        // Add stack to container
        repCounterContainer.addSubview(repCounterStack)
        
        // Add labels to stack with separators
        repCounterStack.addArrangedSubview(totalLabel)
        repCounterStack.addArrangedSubview(separator1)
        repCounterStack.addArrangedSubview(goodLabel)
        repCounterStack.addArrangedSubview(separator2)
        repCounterStack.addArrangedSubview(badLabel)
        
        // Layout constraints for container - positioned to not conflict with record button
        NSLayoutConstraint.activate([
            repCounterContainer.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            repCounterContainer.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            repCounterContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Layout constraints for stack (inset within container)
        NSLayoutConstraint.activate([
            repCounterStack.topAnchor.constraint(equalTo: repCounterContainer.topAnchor, constant: 8),
            repCounterStack.bottomAnchor.constraint(equalTo: repCounterContainer.bottomAnchor, constant: -8),
            repCounterStack.leadingAnchor.constraint(equalTo: repCounterContainer.leadingAnchor, constant: 20),
            repCounterStack.trailingAnchor.constraint(equalTo: repCounterContainer.trailingAnchor, constant: -20)
        ])
    }
    
    /// Sets up gradient overlays at top and bottom of screen for improved text readability
    func setupGradientOverlays() {
        guard let parentView = parentView else { return }
        
        let gradientHeight: CGFloat = 80
        let viewWidth = parentView.bounds.width
        
        // Create top gradient layer
        let topGradient = CAGradientLayer()
        topGradient.frame = CGRect(x: 0, y: 0, width: viewWidth, height: gradientHeight)
        topGradient.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        topGradient.locations = [0.0, 1.0]
        
        // Insert at index 0 to be bottom-most layer
        parentView.layer.insertSublayer(topGradient, at: 0)
        topGradientLayer = topGradient
        
        // Create bottom gradient layer
        let bottomGradient = CAGradientLayer()
        let bottomY = parentView.bounds.height - gradientHeight
        bottomGradient.frame = CGRect(x: 0, y: bottomY, width: viewWidth, height: gradientHeight)
        bottomGradient.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        bottomGradient.locations = [0.0, 1.0]
        
        // Insert at index 0 to be bottom-most layer
        parentView.layer.insertSublayer(bottomGradient, at: 0)
        bottomGradientLayer = bottomGradient
    }
    
    // MARK: - Public Methods
    
    /// Updates the top feedback label with a subtle fade animation
    /// - Parameter message: The feedback message to display
    func updateTextFeedback(message: String) {
        UIView.transition(
            with: topFeedbackLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.topFeedbackLabel.text = message
            },
            completion: nil
        )
    }
    
    /// Updates the rep counter labels with the latest data
    /// Animates the total counter when count increases
    /// - Parameter data: The rep count data to display
    func updateRepCounters(data: RepCountData) {
        // Check if total count increased for animation
        let shouldAnimate = data.totalReps > lastTotalCount
        
        // Update labels
        totalLabel.text = "Total: \(data.totalReps)"
        goodLabel.text = "Good: \(data.goodFormReps)"
        badLabel.text = "Bad: \(data.badFormReps)"
        
        // Animate if total count increased
        if shouldAnimate {
            animateCounterIncrease()
        }
        
        // Store current total for next comparison
        lastTotalCount = data.totalReps
    }
    
    /// Animates the rep counter container with a subtle scale effect
    private func animateCounterIncrease() {
        // Scale up to 1.1
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.repCounterContainer.transform = CGAffineTransform(scaleX: 1.1, scaleY: 1.1)
        }) { [weak self] _ in
            // Scale back to 1.0
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                self?.repCounterContainer.transform = .identity
            })
        }
    }
    
    /// Shows all overlay components
    func show() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.topFeedbackContainer.alpha = 1.0
            self?.repCounterContainer.alpha = 1.0
        }
    }
    
    /// Hides all overlay components
    func hide() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.topFeedbackContainer.alpha = 0.0
            self?.repCounterContainer.alpha = 0.0
        }
    }
    
    /// Resets the overlay to initial state
    func reset() {
        lastTotalCount = 0
        topFeedbackLabel.text = "Ready to analyze your form"
        totalLabel.text = "Total: 0"
        goodLabel.text = "Good: 0"
        badLabel.text = "Bad: 0"
    }
}

