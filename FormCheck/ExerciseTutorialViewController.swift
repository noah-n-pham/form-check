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
    
    var exercise: Exercise?
    private var exerciseName: String {
        return exercise?.name ?? "Exercise"
    }
    
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
    
    private let videoPlaceholderView: UIImageView = {
        let imageView = UIImageView()
        // Try to load an asset named "squat_animation" (add the attached GIF or an image sequence
        // to Assets.xcassets with this name). If it's present, it'll be used here. If not, we keep
        // the dark placeholder background until the asset is added in Xcode.
        if let anim = UIImage(named: "squat_animation") {
            imageView.image = anim
        } else {
            imageView.backgroundColor = .darkGray
        }
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        label.text = ""
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let figureImageView: UIImageView = {
        let imageView = UIImageView()
        // Prefer a bundled asset named "quadriceps_muscles" (add the attached image to Assets.xcassets
        // with that name). If it's not available (e.g., running on Windows or before adding the asset),
        // fall back to the system symbol.
        if let bundled = UIImage(named: "quadriceps_muscles") {
            imageView.image = bundled
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
            imageView.image = UIImage(systemName: "figure.stand", withConfiguration: config)
            imageView.tintColor = .white
        }
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
    private let primaryMusclesListLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
    private let secondaryMusclesListLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
        updateContent()
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
        contentView.addSubview(primaryMusclesListLabel)
        contentView.addSubview(secondaryMusclesLabel)
        contentView.addSubview(secondaryMusclesListLabel)
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
            figureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            figureImageView.widthAnchor.constraint(equalToConstant: 100),
            figureImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Primary muscles label
            primaryMusclesLabel.topAnchor.constraint(equalTo: figureImageView.bottomAnchor, constant: 24),
            primaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Primary muscles list (right below primary label)
            primaryMusclesListLabel.topAnchor.constraint(equalTo: primaryMusclesLabel.bottomAnchor, constant: 8),
            primaryMusclesListLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryMusclesListLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Secondary muscles label (placed after primary list with extra margin)
            secondaryMusclesLabel.topAnchor.constraint(equalTo: primaryMusclesListLabel.bottomAnchor, constant: 16),
            secondaryMusclesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            secondaryMusclesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Secondary muscles list (right below secondary label)
            secondaryMusclesListLabel.topAnchor.constraint(equalTo: secondaryMusclesLabel.bottomAnchor, constant: 8),
            secondaryMusclesListLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            secondaryMusclesListLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            secondaryMusclesListLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Understand button
            understandButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            understandButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            understandButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            understandButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Update Content
    
    private func updateContent() {
        guard let exercise = exercise else { return }
        
        // Update navigation title
        title = exerciseName
        
        // Update description
        descriptionLabel.text = exercise.description
        
        // Update primary muscles
        primaryMusclesListLabel.text = exercise.primaryMuscles
        
        // Update secondary muscles
        secondaryMusclesListLabel.text = exercise.secondaryMuscles
        
        // Update tutorial image
        if let bundled = UIImage(named: exercise.tutorialImageName) {
            figureImageView.image = bundled
        }
        
        // Update animation/video placeholder
        if let anim = UIImage(named: exercise.animationAssetName) {
            videoPlaceholderView.image = anim
            videoPlaceholderLabel.isHidden = true
        } else {
            videoPlaceholderView.image = nil
            videoPlaceholderView.backgroundColor = .darkGray
            videoPlaceholderLabel.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @objc private func understandButtonTapped() {
        let demoVC = TutorialDemoViewController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
}

