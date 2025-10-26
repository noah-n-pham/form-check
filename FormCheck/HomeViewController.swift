//
//  HomeViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Home screen with start button
final class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Squat Analysis", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FormCheck"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI-Powered Squat Form Analysis"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Home"
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(startButton)
        
        // Add button action
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            
            // Subtitle label
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            // Start button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 280),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        // TEMPORARY: Navigate to test view instead of production view
        let cameraTestVC = CameraTestViewController()
        navigationController?.pushViewController(cameraTestVC, animated: true)
        
        // Production view (will use this later):
        // let cameraVC = CameraViewController()
        // navigationController?.pushViewController(cameraVC, animated: true)
    }
}

