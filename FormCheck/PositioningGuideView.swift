//
//  PositioningGuideView.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Overlay view that guides user to position themselves correctly for body detection
final class PositioningGuideView: UIView {
    
    // MARK: - UI Components
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Position yourself 6 feet away, side view"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stickFigureView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stickFigureLayer = CAShapeLayer()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Semi-transparent black background (60% opacity)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // Add subviews
        addSubview(instructionLabel)
        addSubview(stickFigureView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Instruction label - top third
            instructionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 100),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            // Stick figure - center
            stickFigureView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stickFigureView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stickFigureView.widthAnchor.constraint(equalToConstant: 120),
            stickFigureView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Setup stick figure layer
        stickFigureLayer.strokeColor = UIColor.white.cgColor
        stickFigureLayer.fillColor = UIColor.clear.cgColor
        stickFigureLayer.lineWidth = 3.0
        stickFigureLayer.lineCap = .round
        stickFigureLayer.lineJoin = .round
        stickFigureView.layer.addSublayer(stickFigureLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawStickFigure()
    }
    
    // MARK: - Drawing
    
    private func drawStickFigure() {
        let bounds = stickFigureView.bounds
        let path = UIBezierPath()
        
        // Scale factors for positioning
        let centerX = bounds.width / 2
        let headRadius: CGFloat = 15
        let bodyTop: CGFloat = 35
        let bodyBottom: CGFloat = 100
        let hipY: CGFloat = 100
        let kneeY: CGFloat = 140
        let ankleY: CGFloat = 180
        let shoulderY: CGFloat = 45
        let armWidth: CGFloat = 30
        
        // Draw head (circle)
        let headCenter = CGPoint(x: centerX, y: headRadius + 5)
        path.addArc(
            withCenter: headCenter,
            radius: headRadius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        // Draw body (vertical line from shoulders to hips)
        path.move(to: CGPoint(x: centerX, y: bodyTop))
        path.addLine(to: CGPoint(x: centerX, y: bodyBottom))
        
        // Draw left arm
        path.move(to: CGPoint(x: centerX, y: shoulderY))
        path.addLine(to: CGPoint(x: centerX - armWidth, y: shoulderY + 15))
        
        // Draw right arm
        path.move(to: CGPoint(x: centerX, y: shoulderY))
        path.addLine(to: CGPoint(x: centerX + armWidth, y: shoulderY + 15))
        
        // Draw left leg (hip to knee to ankle)
        path.move(to: CGPoint(x: centerX, y: hipY))
        path.addLine(to: CGPoint(x: centerX - 15, y: kneeY))
        path.addLine(to: CGPoint(x: centerX - 10, y: ankleY))
        
        // Draw right leg (hip to knee to ankle)
        path.move(to: CGPoint(x: centerX, y: hipY))
        path.addLine(to: CGPoint(x: centerX + 15, y: kneeY))
        path.addLine(to: CGPoint(x: centerX + 10, y: ankleY))
        
        // Set the path
        stickFigureLayer.path = path.cgPath
    }
    
    // MARK: - Animation
    
    /// Shows the guide with fade-in animation
    func show(animated: Bool = true) {
        guard isHidden else { return }
        
        if animated {
            alpha = 0
            isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
            }
        } else {
            isHidden = false
            alpha = 1.0
        }
    }
    
    /// Hides the guide with fade-out animation
    func hide(animated: Bool = true) {
        guard !isHidden else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in
                self.isHidden = true
                self.alpha = 1.0
            }
        } else {
            isHidden = true
        }
    }
}

