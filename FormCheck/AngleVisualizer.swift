//
//  AngleVisualizer.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit
import AVFoundation

/// Visualizes joint angles on the camera preview with arc indicators
/// Provides real-time visual feedback on form quality
final class AngleVisualizer {
    
    // MARK: - Properties
    
    /// Reference to the preview layer for coordinate conversion
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Reusable arc shape layer for angle visualization
    private var arcLayer: CAShapeLayer?
    
    /// Reusable text layer for angle value display
    private var textLayer: CATextLayer?
    
    /// Container view for the layers
    private weak var containerView: UIView?
    
    // MARK: - Initialization
    
    /// Initializes the angle visualizer
    /// - Parameters:
    ///   - previewLayer: The camera preview layer for coordinate reference
    ///   - containerView: The view to add visualization layers to
    init(previewLayer: AVCaptureVideoPreviewLayer, containerView: UIView) {
        self.previewLayer = previewLayer
        self.containerView = containerView
    }
    
    // MARK: - Public Methods
    
    /// Shows an angle indicator at the specified joint position
    /// - Parameters:
    ///   - jointPosition: The position of the joint where the angle is measured
    ///   - angle: The angle value in degrees
    ///   - isGoodForm: Whether the current form is good (affects color if needed)
    ///   - vectorStart: Start point of the angle vector
    ///   - vectorEnd: End point of the angle vector
    func showAngleIndicator(
        at jointPosition: CGPoint,
        angle: Double,
        isGoodForm: Bool,
        vectorStart: CGPoint,
        vectorEnd: CGPoint
    ) {
        guard let containerView = containerView else { return }
        
        // Determine arc color based on angle range
        let arcColor = (angle >= 80 && angle <= 100) ? UIColor.systemGreen : UIColor.systemRed
        
        // Calculate angles for the arc based on vectors
        let startAngle = calculateAngle(from: jointPosition, to: vectorStart)
        let endAngle = calculateAngle(from: jointPosition, to: vectorEnd)
        
        // Create or update arc layer
        let arc = getOrCreateArcLayer()
        updateArcLayer(arc, at: jointPosition, startAngle: startAngle, endAngle: endAngle, color: arcColor)
        
        // Ensure arc is added to container
        if arc.superlayer == nil {
            containerView.layer.addSublayer(arc)
        }
        
        // Create or update text layer
        let text = getOrCreateTextLayer()
        let textPosition = calculateTextPosition(near: jointPosition, radius: 40)
        updateTextLayer(text, with: angle, at: textPosition)
        
        // Ensure text is added to container
        if text.superlayer == nil {
            containerView.layer.addSublayer(text)
        }
    }
    
    /// Hides the angle indicator by removing layers
    func hideAngleIndicator() {
        arcLayer?.removeFromSuperlayer()
        textLayer?.removeFromSuperlayer()
    }
    
    // MARK: - Private Methods - Layer Management
    
    /// Gets existing arc layer or creates a new one
    private func getOrCreateArcLayer() -> CAShapeLayer {
        if let existing = arcLayer {
            return existing
        }
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3.0
        layer.lineCap = .round
        arcLayer = layer
        return layer
    }
    
    /// Gets existing text layer or creates a new one
    private func getOrCreateTextLayer() -> CATextLayer {
        if let existing = textLayer {
            return existing
        }
        
        let layer = CATextLayer()
        layer.fontSize = 14
        layer.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        layer.alignmentMode = .center
        layer.foregroundColor = UIColor.white.cgColor
        layer.contentsScale = UIScreen.main.scale
        
        // Add shadow for black outline effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.0
        
        textLayer = layer
        return layer
    }
    
    /// Updates the arc layer with new position and appearance
    private func updateArcLayer(
        _ layer: CAShapeLayer,
        at center: CGPoint,
        startAngle: CGFloat,
        endAngle: CGFloat,
        color: UIColor
    ) {
        let radius: CGFloat = 40
        
        // Create arc path
        let arcPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        layer.path = arcPath.cgPath
        layer.strokeColor = color.cgColor
    }
    
    /// Updates the text layer with angle value and position
    private func updateTextLayer(_ layer: CATextLayer, with angle: Double, at position: CGPoint) {
        let angleText = String(format: "%.0f°", angle)
        layer.string = angleText
        
        // Calculate text size for positioning
        let textSize = CGSize(width: 50, height: 20)
        layer.frame = CGRect(
            x: position.x - textSize.width / 2,
            y: position.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
    }
    
    // MARK: - Private Methods - Calculations
    
    /// Calculates the angle in radians from one point to another
    /// - Parameters:
    ///   - from: Starting point (center)
    ///   - to: Ending point
    /// - Returns: Angle in radians
    private func calculateAngle(from: CGPoint, to: CGPoint) -> CGFloat {
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        return atan2(deltaY, deltaX)
    }
    
    /// Calculates optimal position for text label near the joint
    /// - Parameters:
    ///   - jointPosition: The joint position
    ///   - radius: The radius of the arc
    /// - Returns: Position for the text label
    private func calculateTextPosition(near jointPosition: CGPoint, radius: CGFloat) -> CGPoint {
        // Position text slightly above and to the right of the joint
        let offset: CGFloat = radius + 20
        return CGPoint(
            x: jointPosition.x + offset,
            y: jointPosition.y - offset
        )
    }
}

