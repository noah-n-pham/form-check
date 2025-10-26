//
//  ExerciseTutorialViewController.swift
//  FormCheck
//
//  Created for GatorHack
//

import UIKit

/// Tutorial screen showing exercise information and proper form
final class ExerciseTutorialViewController: UIViewController {
    
    // MARK: - Properties
    
    var exerciseName: String = "Barbell Back Squats"
    
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
    
    private let videoPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let videoPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tutorial of ideal form"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let figureImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        imageView.image = UIImage(systemName: "figure.stand", withConfiguration: config)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let primaryMusclesLabel: UILabel = {
        let label = UILabel()
        label.text = "Primary Muscles:"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let secondaryMusclesLabel: UILabel = {
        let label = UILabel()
        label.text = "Secondary Muscles:"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
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
        title = exerciseName
        
        // Configure navigation bar
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(videoPlaceholderView)
        videoPlaceholderView.addSubview(videoPlaceholderLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(figureImageView)
        contentView.addSubview(primaryMusclesLabel)
        contentView.addSubview(secondaryMusclesLabel)
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
            
            // Video placeholder
            videoPlaceholderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            videoPlaceholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            videoPlaceholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            videoPlaceholderView.heightAnchor.constraint(equalToConstant: 200),
            
            // Video placeholder label
            videoPlaceholderLabel.centerXAnchor.constraint(equalTo: videoPlaceholderView.centerXAnchor),
            videoPlaceholderLabel.centerYAnchor.constraint(equalTo: videoPlaceholderView.centerYAnchor),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: videoPlaceholderView.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Figure image
            figureImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            figureImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            figureImageView.widthAnchor.constraint(equalToConstant: 100),
            figureImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Primary muscles label
            primaryMusclesLabel.topAnchor.constraint(equalTo: figureImageView.bottomAnchor, constant: 24),
            primaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Secondary muscles label
            secondaryMusclesLabel.topAnchor.constraint(equalTo: primaryMusclesLabel.bottomAnchor, constant: 16),
            secondaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            secondaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            secondaryMusclesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Understand button
            understandButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            understandButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            understandButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            understandButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func understandButtonTapped() {
        let demoVC = TutorialDemoViewController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
}

