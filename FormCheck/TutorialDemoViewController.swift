//
//  TutorialDemoViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Demo screen showing setup instructions before starting exercise
final class TutorialDemoViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Before you begin:"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Step 1
    private let step1Label: UILabel = {
        let label = UILabel()
        label.text = "1. Place your camera at a side angle view."
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let step1ImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let step1PlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Example Image"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Step 2
    private let step2Label: UILabel = {
        let label = UILabel()
        label.text = "2. Record the video"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let step2ImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let step2PlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Example Image"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Step 3
    private let step3Label: UILabel = {
        let label = UILabel()
        label.text = "3. Stop the video and see the results"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let understandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I understand", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Configure navigation bar
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(step1Label)
        contentView.addSubview(step1ImageView)
        step1ImageView.addSubview(step1PlaceholderLabel)
        contentView.addSubview(step2Label)
        contentView.addSubview(step2ImageView)
        step2ImageView.addSubview(step2PlaceholderLabel)
        contentView.addSubview(step3Label)
        view.addSubview(understandButton)
        
        // Add button action
        understandButton.addTarget(self, action: #selector(understandButtonTapped), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: understandButton.topAnchor, constant: -16),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Step 1 label
            step1Label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            step1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            step1Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Step 1 image
            step1ImageView.topAnchor.constraint(equalTo: step1Label.bottomAnchor, constant: 16),
            step1ImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            step1ImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            step1ImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Step 1 placeholder label
            step1PlaceholderLabel.centerXAnchor.constraint(equalTo: step1ImageView.centerXAnchor),
            step1PlaceholderLabel.centerYAnchor.constraint(equalTo: step1ImageView.centerYAnchor),
            
            // Step 2 label
            step2Label.topAnchor.constraint(equalTo: step1ImageView.bottomAnchor, constant: 24),
            step2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            step2Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Step 2 image
            step2ImageView.topAnchor.constraint(equalTo: step2Label.bottomAnchor, constant: 16),
            step2ImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            step2ImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            step2ImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Step 2 placeholder label
            step2PlaceholderLabel.centerXAnchor.constraint(equalTo: step2ImageView.centerXAnchor),
            step2PlaceholderLabel.centerYAnchor.constraint(equalTo: step2ImageView.centerYAnchor),
            
            // Step 3 label
            step3Label.topAnchor.constraint(equalTo: step2ImageView.bottomAnchor, constant: 24),
            step3Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            step3Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            step3Label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Understand button
            understandButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            understandButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            understandButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            understandButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func understandButtonTapped() {
        let cameraVC = CameraViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}

